using eCinema.Models.DTOs.Users;
using eCinema.Models.Entities;
using eCinema.Models.SearchObjects;
using eCinema.Services.Interfaces;
using eCinema.Services.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace eCinema.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class UserController : BaseCRUDController<UserDto, ActorSearch, UserInsertDto, UserUpdateDto>
    {
        private readonly IUserService _userService;
        public UserController(
            ILogger<BaseController<UserDto, ActorSearch>> logger,
            IUserService service)
            : base(logger, service)
        {
            _userService = service;
        }
        [Authorize(Roles = "Admin")]
        public override Task<UserDto> Insert([FromBody] UserInsertDto insert)
        {
            return base.Insert(insert);
        }

        [HttpPost("{id:int}/profile-picture")]
        public async Task<IActionResult> UploadPicture(int id, IFormFile image)
        {
            await _userService.SetProfilePictureAsync(id, image);
            return NoContent();
        }

        [HttpGet("{id:int}/profile-picture")]
        public async Task<IActionResult> GetPicture(int id)
        {
            var pic = await _userService.GetProfilePictureAsync(id);
            return pic == null
                 ? NotFound()
                 : File(pic.Value.Data, pic.Value.ContentType);
        }
    }
}
