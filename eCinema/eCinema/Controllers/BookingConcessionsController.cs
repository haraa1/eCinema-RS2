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
        : BaseCRUDController<BookingConcessionDto, BookingConcessionSearchObject, BookingConcessionInsertDto, BookingConcessionUpdateDto>
    {
        public BookingConcessionsController(
            ILogger<BaseController<BookingConcessionDto, BookingConcessionSearchObject>> logger,
            IBookingConcessionsService service)
            : base(logger, service)
        {
        }
    }
}
