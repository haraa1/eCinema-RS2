using eCinema.Models.DTOs.Users;
using eCinema.Models.Entities;
using eCinema.Models.SearchObjects;
using eCinema.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace eCinema.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class UserController : BaseCRUDController<UserDto, ActorSearch, UserInsertDto, UserUpdateDto>
    {
        public UserController(
            ILogger<BaseController<UserDto, ActorSearch>> logger,
            IUserService service)
            : base(logger, service)
        {
        }
        [Authorize(Roles = "admin")]
        public override Task<UserDto> Insert([FromBody] UserInsertDto insert)
        {
            return base.Insert(insert);
        }
    }
}
