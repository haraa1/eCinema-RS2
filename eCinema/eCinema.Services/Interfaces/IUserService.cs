using eCinema.Models.DTOs.Showtimes;
using eCinema.Models.DTOs.Users;
using eCinema.Models.Entities;
using eCinema.Models.SearchObjects;
using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Services.Interfaces
{
    public interface IUserService : ICRUDService<UserDto, ActorSearch, UserInsertDto, UserUpdateDto>
    {
        Task<UserDto> Authenticate(string username, string password);
        Task SetProfilePictureAsync(int id, IFormFile file);
        Task<(byte[] Data, string ContentType)?> GetProfilePictureAsync(int id);
        Task<UserDto> UpdateLanguage(int userId, string language);
        Task<UserDto> UpdateProfileAsync(int userId, UserProfileUpdateDto dto);
        Task<UserDto> UpdateNotifyAsync(int userId, bool notify);
    }
}
