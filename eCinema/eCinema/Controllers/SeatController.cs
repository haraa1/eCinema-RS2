using eCinema.Models.DTOs.Movies;
using eCinema.Models.DTOs.Seats;
using eCinema.Models.SearchObjects;
using eCinema.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace eCinema.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class SeatController : BaseCRUDController<SeatDto, BaseSearchObject, SeatInsertDto, SeatUpdateDto>
    {
        public SeatController(
            ILogger<BaseController<SeatDto, BaseSearchObject>> logger,
            ISeatService service)
            : base(logger, service)
        {
        }


    }
}
