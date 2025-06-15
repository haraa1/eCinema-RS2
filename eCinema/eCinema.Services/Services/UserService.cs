using AutoMapper;
using eCinema.Model.Entities;
using eCinema.Models;
using eCinema.Models.DTOs.Users;
using eCinema.Models.Entities;
using eCinema.Models.SearchObjects;
using eCinema.Services.Interfaces;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Services.Services
{
    public class UserService : BaseCRUDService<UserDto, User, ActorSearch, UserInsertDto, UserUpdateDto>, IUserService
    {
        public UserService(eCinemaDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<User> AddFilter(IQueryable<User> query, ActorSearch? search = null)
        {
            var filteredQuery = base.AddFilter(query, search);

            if (!string.IsNullOrWhiteSpace(search?.Name))
            {
                filteredQuery = filteredQuery.Where(x => x.UserName.Contains(search.Name));
            }

            return filteredQuery;
        }

        public override async Task BeforeInsert(User entity, UserInsertDto insert)
        {
            if (await _context.User.AnyAsync(u => u.UserName == insert.UserName))
                throw new ArgumentException("Username is already taken");

            if (await _context.User.AnyAsync(u => u.Email == insert.Email))
                throw new ArgumentException("Email is already taken");

            entity.PasswordSalt = GenerateSalt();
            entity.PasswordHash = GenerateHash(entity.PasswordSalt, insert.Password);

            if (insert.RoleIds == null || !insert.RoleIds.Any())
            {
                insert.RoleIds = await _context.Roles
                                  .Where(r => r.Name == "User")
                                  .Select(r => r.Id)
                                  .ToListAsync();
            }

            foreach (var roleId in insert.RoleIds)
            {
                entity.UserRoles.Add(new UserRole { RoleId = roleId });
            }
        }

        public override async Task<UserDto> Insert(UserInsertDto dto)
        {
            var entity = _mapper.Map<User>(dto);

            await BeforeInsert(entity, dto);

            _context.User.Add(entity);
            await _context.SaveChangesAsync();

            var fresh = await _context.User
                .Include(u => u.UserRoles)
                    .ThenInclude(ur => ur.Role)
                .SingleAsync(u => u.Id == entity.Id);

            return _mapper.Map<UserDto>(fresh);
        }



        public override async Task<UserDto> Update(int id, UserUpdateDto update)
        {
            var entity = await _context.Set<User>()
                .Include(u => u.UserRoles)
                .FirstOrDefaultAsync(u => u.Id == id);
            if (entity == null)
                throw new Exception("User not found.");

            _mapper.Map(update, entity);

            if (update.RoleIds != null)
            {
                entity.UserRoles.Clear();
                foreach (var roleId in update.RoleIds)
                {
                    var role = await _context.Roles.FindAsync(roleId);
                    if (role != null)
                    {
                        entity.UserRoles.Add(new UserRole { RoleId = roleId, Role = role });
                    }
                }
            }

            await _context.SaveChangesAsync();
            return _mapper.Map<UserDto>(entity);
        }

        public override async Task<UserDto> GetById(int id)
        {
            var entity = await _context.User
                .Include(u => u.UserRoles)
                    .ThenInclude(ur => ur.Role)
                .FirstOrDefaultAsync(u => u.Id == id);

            if (entity == null)
                throw new Exception("User not found.");

            return _mapper.Map<UserDto>(entity);
        }

        public override IQueryable<User> AddInclude(IQueryable<User> query, ActorSearch search = null)
        {
            query = query.Include(u => u.UserRoles)
                         .ThenInclude(ur => ur.Role);
            return base.AddInclude(query, search);
        }

        public override async Task<bool> Delete(int id)
        {
            var user = await _context.User
                .Include(u => u.UserRoles)
                .FirstOrDefaultAsync(u => u.Id == id);

            if (user == null)
                throw new Exception("User not found.");

            foreach (var userRole in user.UserRoles.ToList())
            {
                _context.UserRoles.Remove(userRole);
            }

            _context.User.Remove(user);
            await _context.SaveChangesAsync();

            return true;
        }
        public async Task<UserDto> Authenticate(string username, string password)
        {
            var entity = await _context.User
                .Include(u => u.UserRoles)
                    .ThenInclude(ur => ur.Role)
                .FirstOrDefaultAsync(x => x.UserName == username);

            if (entity == null)
                return null;

            var computedHash = GenerateHash(entity.PasswordSalt, password);
            if (computedHash != entity.PasswordHash)
                return null;

            return _mapper.Map<UserDto>(entity);
        }

        public static string GenerateSalt()
        {
            byte[] saltBytes = new byte[16];
            using (var rng = RandomNumberGenerator.Create())
            {
                rng.GetBytes(saltBytes);
            }
            return Convert.ToBase64String(saltBytes);
        }

        public static string GenerateHash(string salt, string password)
        {
            var saltBytes = Convert.FromBase64String(salt);
            var passwordBytes = Encoding.UTF8.GetBytes(password);
            var combinedBytes = new byte[saltBytes.Length + passwordBytes.Length];

            Buffer.BlockCopy(saltBytes, 0, combinedBytes, 0, saltBytes.Length);
            Buffer.BlockCopy(passwordBytes, 0, combinedBytes, saltBytes.Length, passwordBytes.Length);

            using (var sha256 = SHA256.Create())
            {
                var hashBytes = sha256.ComputeHash(combinedBytes);
                return Convert.ToBase64String(hashBytes);
            }
        }

        public async Task SetProfilePictureAsync(int id, IFormFile file)
        {
            var user = await _context.User.FindAsync(id)
                       ?? throw new KeyNotFoundException("User not found");

            await using var ms = new MemoryStream();
            await file.CopyToAsync(ms);
            user.ProfilePicture = ms.ToArray();

            await _context.SaveChangesAsync();
        }

        public async Task<(byte[] Data, string ContentType)?> GetProfilePictureAsync(int id)
        {
            var data = await _context.User
                       .Where(u => u.Id == id)
                       .Select(u => u.ProfilePicture)
                       .SingleOrDefaultAsync();

            return data == null ? null : (data, "image/jpeg");
        }

        public async Task<UserDto> UpdateLanguage(int userId, string language)
        {
            var user = await _context.User.FindAsync(userId);
            if (user == null) return null;

            user.PreferredLanguage = language;
            _context.Entry(user).Property(u => u.PreferredLanguage).IsModified = true;

            await _context.SaveChangesAsync();
            return _mapper.Map<UserDto>(user);
        }

        public async Task<UserDto> UpdateProfileAsync(int userId, UserProfileUpdateDto dto)
        {
            var user = await _context.User
                .Include(u => u.UserRoles)
                    .ThenInclude(ur => ur.Role)
                .FirstOrDefaultAsync(u => u.Id == userId);

            if (user == null)
            {
                throw new KeyNotFoundException("User not found.");
            }

            bool changed = false;

            if (!string.IsNullOrWhiteSpace(dto.NewPassword))
            {
                if (string.IsNullOrWhiteSpace(dto.CurrentPassword))
                {
                    throw new ArgumentException("Current password is required to set a new password.");
                }

                var currentPasswordHash = GenerateHash(user.PasswordSalt, dto.CurrentPassword);
                if (currentPasswordHash != user.PasswordHash)
                {
                    throw new ArgumentException("Invalid current password.");
                }

                if (dto.NewPassword != dto.ConfirmNewPassword)
                {
                    throw new ArgumentException("New password and confirmation password do not match.");
                }

                user.PasswordSalt = GenerateSalt();
                user.PasswordHash = GenerateHash(user.PasswordSalt, dto.NewPassword);
                changed = true;
            }
            else if (!string.IsNullOrWhiteSpace(dto.CurrentPassword) || !string.IsNullOrWhiteSpace(dto.ConfirmNewPassword))
            {
                throw new ArgumentException("New password cannot be empty if you intend to change it. Please provide a new password or clear all password fields.");
            }
            if (dto.PhoneNumber != null && user.PhoneNumber != dto.PhoneNumber)
            {
                user.PhoneNumber = dto.PhoneNumber;
                changed = true;
            }

            if (!string.IsNullOrWhiteSpace(dto.PreferredLanguage) && user.PreferredLanguage != dto.PreferredLanguage)
            {
                user.PreferredLanguage = dto.PreferredLanguage;
                changed = true;
            }

            if (changed)
            {
                await _context.SaveChangesAsync();
            }
            return _mapper.Map<UserDto>(user);
        }
    }
}
