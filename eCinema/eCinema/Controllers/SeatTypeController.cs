using eCinema.Models.DTOs.Seats;
using eCinema.Models.DTOs.SeatTypes;
using eCinema.Models.SearchObjects;
using eCinema.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace eCinema.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class SeatTypeController : BaseCRUDController<SeatTypeDto, BaseSearchObject, SeatTypeInsert, SeatTypeUpdateDto>
    {
        public SeatTypeController(
            ILogger<BaseController<SeatTypeDto, BaseSearchObject>> logger,
            ISeatTypeService service)
            : base(logger, service)
        {
        }


    }
}
