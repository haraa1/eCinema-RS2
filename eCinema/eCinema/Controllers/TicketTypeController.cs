using eCinema.Models.DTOs.Movies;
using eCinema.Models.DTOs.TicketTypes;
using eCinema.Models.SearchObjects;
using eCinema.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace eCinema.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class TicketTypeController : BaseCRUDController<TicketTypeDto, NameSearchObject, TicketTypeInsertDto, TicketTypeUpdateDto>
    {
        public TicketTypeController(
            ILogger<BaseController<TicketTypeDto, NameSearchObject>> logger,
            ITicketTypeService service)
            : base(logger, service)
        {
        }
    }
}
