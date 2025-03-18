using eCinema.Models.DTOs.Concessions;
using eCinema.Models.SearchObjects;
using eCinema.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace eCinema.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ConcessionController : BaseCRUDController<ConcessionDto, NameSearchObject, ConcessionInsertDto, ConcessionUpdateDto>
    {
        public ConcessionController(
            ILogger<BaseController<ConcessionDto, NameSearchObject>> logger,
            IConcessionService service)
            : base(logger, service)
        {
        }


    }
}
