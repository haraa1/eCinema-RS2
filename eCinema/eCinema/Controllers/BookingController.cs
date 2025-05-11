using eCinema.Models.DTOs.Movies;
using eCinema.Models.DTOs.Bookings;
using eCinema.Models.SearchObjects;
using eCinema.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;

namespace eCinema.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class BookingController : BaseCRUDController<BookingDto, BaseSearchObject, BookingInsertDto, BookingUpdateDto>
    {
        private readonly IBookingService _service;
        public BookingController(
            ILogger<BaseController<BookingDto, BaseSearchObject>> logger,
            IBookingService service)
            : base(logger, service)
        {
            _service = service;
        }

        [Authorize]
        [HttpGet("me")]
        public async Task<IActionResult> GetCurrentUserBookings()
        {
            var list = await _service.GetCurrentUserBookings();
            return Ok(list);
        }
    }
}
