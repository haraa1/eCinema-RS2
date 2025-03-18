using eCinema.Models.DTOs.Actors;
using eCinema.Models.DTOs.Genres;
using eCinema.Models.SearchObjects;
using eCinema.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace eCinema.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class GenreController : BaseCRUDController<GenreDto, NameSearchObject, GenreInsertDto, GenreUpdateDto>
    {
        public GenreController(
            ILogger<BaseController<GenreDto, NameSearchObject>> logger,
            IGenreService service)
            : base(logger, service)
        {
        }


    }
}
