using eCinema.Models.DTOs.Seats;
using eCinema.Models.DTOs.Showtimes;
using eCinema.Models.SearchObjects;
using eCinema.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace eCinema.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ShowtimeController : BaseCRUDController<ShowtimeDto, ShowtimeSearchObject, ShowtimeInsertDto, ShowtimeUpdateDto>
    {
        public ShowtimeController(
            ILogger<BaseController<ShowtimeDto, ShowtimeSearchObject>> logger,
            IShowtimeService service)
            : base(logger, service)
        {
        }


    }
}
