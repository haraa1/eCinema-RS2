using AutoMapper;
using eCinema.Models.DTOs.SeatTypes;
using eCinema.Models.Entities;
using eCinema.Models.SearchObjects;
using eCinema.Models;
using eCinema.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using eCinema.Models.DTOs.Users;
using Microsoft.EntityFrameworkCore;
using System.Security.Cryptography;

namespace eCinema.Services.Services
{
    public class UserService : BaseCRUDService<UserDto, User, ActorSearch, UserInsertDto, UserUpdateDto>, IUserService
    {
        public UserService(eCinemaDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override async Task BeforeInsert(User entity, UserInsertDto insert)
        {
            entity.PasswordSalt = GenerateSalt();
            entity.PasswordHash = GenerateHash(entity.PasswordSalt, insert.Password);
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
