using eCinema.Models.DTOs.CinemaHalls;
using eCinema.Models.DTOs.Seats;
using eCinema.Models.SearchObjects;
using eCinema.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace eCinema.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class CinemaHallController : BaseCRUDController<CinemaHallDto, BaseSearchObject, CinemaHallInsertDto, CinemaHallUpdateDto>
    {
        private readonly ICinemaHallService _cinemaHallService;

        public CinemaHallController(
            ILogger<BaseController<CinemaHallDto, BaseSearchObject>> logger,
            ICinemaHallService cinemaHallService)
            : base(logger, cinemaHallService)
        {
            _cinemaHallService = cinemaHallService;
        }

        [HttpGet("{id}/seat-distribution")]
        public async Task<IActionResult> GetSeatDistribution(int id)
        {
            try
            {
                var distribution = await _cinemaHallService.GetSeatDistribution(id);
                return Ok(distribution);
            }
            catch (Exception ex)
            {
                return NotFound(new { message = ex.Message });
            }
        }
        [HttpPut("{id}/seat-distribution")]
        public async Task<IActionResult> UpdateSeatDistribution(int id, [FromBody] UpdateSeatDistributionDto dto)
        {
            try
            {
                await _cinemaHallService.UpdateSeatDistribution(id, dto);
                return NoContent();
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("{id}/seats")]
        public async Task<IActionResult> AddSeats(int id, [FromBody] AddSeatsDto dto)
        {
            try
            {
                await _cinemaHallService.AddSeats(id, dto);
                return NoContent();
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpDelete("{id}/seats")]
        public async Task<IActionResult> RemoveSeats(int id, [FromBody] RemoveSeatsDto dto)
        {
            try
            {
                await _cinemaHallService.RemoveSeats(id, dto);
                return NoContent();
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPut("{id}/seats/bulk")]
        public async Task<IActionResult> BulkUpdateSeats(int id, [FromBody] BulkUpdateSeatsDto dto)
        {
            try
            {
                await _cinemaHallService.BulkUpdateSeats(id, dto);
                return NoContent();
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}