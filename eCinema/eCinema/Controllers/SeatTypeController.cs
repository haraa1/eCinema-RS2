using eCinema.Models.DTOs.Seats;
using eCinema.Models.DTOs.SeatTypes;
using eCinema.Models.SearchObjects;
using eCinema.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace eCinema.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class SeatTypeController : BaseCRUDController<SeatTypeDto, NameSearchObject, SeatTypeInsert, SeatTypeUpdateDto>
    {
        public SeatTypeController(
            ILogger<BaseController<SeatTypeDto, NameSearchObject>> logger,
            ISeatTypeService service)
            : base(logger, service)
        {
        }


    }
}
