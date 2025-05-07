using eCinema.Models.DTOs.Movies;
using eCinema.Models.DTOs.Bookings;
using eCinema.Models.SearchObjects;
using eCinema.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace eCinema.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class BookingController : BaseCRUDController<BookingDto, BaseSearchObject, BookingInsertDto, BookingUpdateDto>
    {
        public BookingController(
            ILogger<BaseController<BookingDto, BaseSearchObject>> logger,
            IBookingService service)
            : base(logger, service)
        {
        }
    }
}
