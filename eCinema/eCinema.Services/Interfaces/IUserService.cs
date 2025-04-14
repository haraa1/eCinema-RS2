using eCinema.Models.DTOs.Showtimes;
using eCinema.Models.DTOs.Users;
using eCinema.Models.Entities;
using eCinema.Models.SearchObjects;
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
    }
}
