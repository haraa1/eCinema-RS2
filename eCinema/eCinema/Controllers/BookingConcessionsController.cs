using eCinema.Models.DTOs.Movies;
using eCinema.Models.DTOs.BookingConcessions;
using eCinema.Models.SearchObjects;
using eCinema.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace eCinema.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class BookingConcessionsController
        : BaseCRUDController<BookingConcessionDto, BaseSearchObject, BookingConcessionInsertDto, BookingConcessionUpdateDto>
    {
        public BookingConcessionsController(
            ILogger<BaseController<BookingConcessionDto, BaseSearchObject>> logger,
            IBookingConcessionsService service)
            : base(logger, service)
        {
        }
    }
}
