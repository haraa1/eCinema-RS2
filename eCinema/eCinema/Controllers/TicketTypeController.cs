using eCinema.Models.DTOs.Movies;
using eCinema.Models.DTOs.TicketTypes;
using eCinema.Models.SearchObjects;
using eCinema.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace eCinema.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class TicketTypeController : BaseCRUDController<TicketTypeDto, BaseSearchObject, TicketTypeInsertDto, TicketTypeUpdateDto>
    {
        public TicketTypeController(
            ILogger<BaseController<TicketTypeDto, BaseSearchObject>> logger,
            ITicketTypeService service)
            : base(logger, service)
        {
        }
    }
}
