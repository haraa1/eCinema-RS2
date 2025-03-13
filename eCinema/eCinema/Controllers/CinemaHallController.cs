using eCinema.Models.DTOs.CinemaHalls;
using eCinema.Models.SearchObjects;
using eCinema.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace eCinema.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class CinemaHallController : BaseCRUDController<CinemaHallDto, BaseSearchObject, CinemaHallInsertDto, CinemaHallUpdateDto>
    {
        public CinemaHallController(
            ILogger<BaseController<CinemaHallDto, BaseSearchObject>> logger,
            ICinemaHallService service)
            : base(logger, service)
        {
        }


    }
}
