using EasyNetQ;
using eCinema.Models.DTOs.Users;
using eCinema.Models.Entities;
using eCinema.Models.Messages;
using eCinema.Models.SearchObjects;
using eCinema.Services.Interfaces;
using eCinema.Services.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace eCinema.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class UserController : BaseCRUDController<UserDto, ActorSearch, UserInsertDto, UserUpdateDto>
    {
        private readonly IUserService _userService;
        private readonly IBus _bus;
        public UserController(
            ILogger<BaseController<UserDto, ActorSearch>> logger,
            IUserService service, IBus bus)
            : base(logger, service)
        {
            _userService = service;
            _bus = bus;
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

        [HttpPost("register")]
        [AllowAnonymous]
        public async Task<ActionResult<UserDto>> Register([FromBody] UserRegisterDto dto)
        {
            if (!ModelState.IsValid) return ValidationProblem(ModelState);

            var insert = new UserInsertDto
            {
                FullName = dto.FullName,
                UserName = dto.UserName,
                Email = dto.Email,
                Password = dto.Password,
                ConfirmPassword = dto.ConfirmPassword,
                PhoneNumber = dto.PhoneNumber,
                RoleIds = null
            };

            var created = await _userService.Insert(insert);
            
            await _bus.PubSub.PublishAsync(new UserRegisteredMessage(created.Id, created.Email, created.UserName, DateTime.UtcNow));
           
            return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
        }

        [Authorize]
        [HttpGet("me")]
        public async Task<ActionResult<UserDto>> Me()
        {
            var idClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(idClaim) || !int.TryParse(idClaim, out var userId))
                return Unauthorized();

            var user = await _userService.GetById(userId);
            if (user == null)
                return NotFound();

            return Ok(user);
        }

        [Authorize]
        [HttpPatch("me/preferences")]
        public async Task<ActionResult<UserDto>> UpdatePreferredLanguage([FromBody] PreferredLanguageDto dto)
        {
            var idClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (!int.TryParse(idClaim, out var userId)) return Unauthorized();

            var updated = await _userService.UpdateLanguage(userId, dto.PreferredLanguage);
            return Ok(updated);
        }


        [Authorize]
        [HttpPut("me/profile")]
        public async Task<ActionResult<UserDto>> UpdateMyProfile([FromBody] UserProfileUpdateDto dto)
        {
            var idClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (!int.TryParse(idClaim, out var userId))
            {
                return Unauthorized("User ID claim not found or invalid.");
            }

            try
            {
                var updatedUser = await _userService.UpdateProfileAsync(userId, dto);
                return Ok(updatedUser);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (ArgumentException ex) 
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, "An unexpected error occurred.");
            }
        }
    }
}
