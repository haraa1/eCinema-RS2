using AutoMapper;
using eCinema.Model.Entities;
using eCinema.Models;
using eCinema.Models.DTOs.Users;
using eCinema.Models.Entities;
using eCinema.Models.SearchObjects;
using eCinema.Services.Interfaces;
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
            entity.PasswordSalt = GenerateSalt();
            entity.PasswordHash = GenerateHash(entity.PasswordSalt, insert.Password);

            if (insert.RoleIds != null && insert.RoleIds.Any())
            {
                var rolesToAdd = await _context.Roles
                                           .Where(r => insert.RoleIds.Contains(r.Id))
                                           .ToListAsync();

                foreach (var role in rolesToAdd)
                {
                    entity.UserRoles.Add(new UserRole { Role = role });
                }
            }
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
    }
}
