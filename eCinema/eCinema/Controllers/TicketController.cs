using eCinema.Models.DTOs.Movies;
using eCinema.Models.DTOs.Tickets;
using eCinema.Models.SearchObjects;
using eCinema.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace eCinema.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class TicketController : BaseCRUDController<TicketDto, BaseSearchObject, TicketInsertDto, TicketUpdateDto>
    {
        public TicketController(
            ILogger<BaseController<TicketDto, BaseSearchObject>> logger,
            ITicketService service)
            : base(logger, service)
        {
        }
    }
}
