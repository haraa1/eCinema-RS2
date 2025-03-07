using eCinema.Models.DTOs.Cinemas;
using eCinema.Models.DTOs.Movies;
using eCinema.Models.SearchObjects;
using eCinema.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace eCinema.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class CinemaController : BaseCRUDController<CinemaDto, CinemaSearch, CinemaInsertDto, CinemaUpdateDto>
    {
        public CinemaController(
            ILogger<BaseController<CinemaDto, CinemaSearch>> logger,
            ICinemaService service)
            : base(logger, service)
        {
        }


    }
}
