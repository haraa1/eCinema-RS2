using eCinema.Models.DTOs.Movies;
using eCinema.Models.SearchObjects;
using eCinema.Services.Interfaces;
using eCinema.Services.Services;
using Microsoft.AspNetCore.Mvc;

namespace eCinema.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class MovieController : BaseCRUDController<MovieDto, MovieSearch, MovieInsertDto, MovieUpdateDto>
    {
        private readonly IMovieService _movieService;
        public MovieController(
            ILogger<BaseController<MovieDto, MovieSearch>> logger,
            IMovieService service)
            : base(logger, service)
        {
            _movieService = service;
        }

        [HttpPost("{id:int}/poster")]
        public async Task<IActionResult> UploadPoster(int id, IFormFile image)
        {
            await _movieService.SetPosterAsync(id, image);
            return NoContent();
        }

        [HttpGet("{id:int}/poster")]
        public async Task<IActionResult> GetPoster(int id)
        {
            var pic = await _movieService.GetPosterAsync(id);
            return pic == null
                 ? NotFound()
                 : File(pic.Value.Data, pic.Value.ContentType);
        }

    }
}
