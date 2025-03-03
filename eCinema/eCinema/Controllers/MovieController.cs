using eCinema.Models.DTOs.Movies;
using eCinema.Models.SearchObjects;
using eCinema.Services;
using Microsoft.AspNetCore.Mvc;

namespace eCinema.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class MovieController : BaseCRUDController<MovieDto, MovieSearch, MovieInsertDto, MovieUpdateDto>
    {
        public MovieController(
            ILogger<BaseController<MovieDto, MovieSearch>> logger,
            IMovieService service)
            : base(logger, service)
        {
        }

        
    }
}
