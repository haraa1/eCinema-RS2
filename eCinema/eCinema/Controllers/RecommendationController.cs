using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using eCinema.Models.DTOs.Showtimes;
using eCinema.Models.SearchObjects;
using eCinema.Services.Interfaces;
using eCinema.Services.Recommendations;
using System.Security.Claims;


namespace eCinema.Controllers
{
    [ApiController]
    [Route("Showtime/")]
    public class ShowtimesController : ControllerBase
    {
        private readonly IRecommendationService _recommender;

        public ShowtimesController(
            IRecommendationService recommender)
        {
            _recommender = recommender;
        }


        [HttpGet("recommendations")]
        public async Task<ActionResult<IReadOnlyList<ShowtimeDto>>> GetRecommendations(int take = 10)
        {
            var claimVal = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (!int.TryParse(claimVal, out var userId))
                return Unauthorized();

            var recs = await _recommender.RecommendAsync(userId, take);
            return Ok(recs);
        }
    }
}
