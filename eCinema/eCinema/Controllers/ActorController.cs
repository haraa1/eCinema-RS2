using eCinema.Models.DTOs.Actors;
using eCinema.Models.DTOs.Movies;
using eCinema.Models.SearchObjects;
using eCinema.Services.Interfaces;
using eCinema.Services.Services;
using Microsoft.AspNetCore.Mvc;

namespace eCinema.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ActorController : BaseCRUDController<ActorDto, ActorSearch, ActorInsertDto, ActorUpdateDto>
    {
        public ActorController(
            ILogger<BaseController<ActorDto, ActorSearch>> logger,
            IActorService service)
            : base(logger, service)
        {
        }


    }
}
