using eCinema.Models.DTOs.Movies;
using eCinema.Models.SearchObjects;
using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Services.Interfaces
{
    public interface IMovieService : ICRUDService<MovieDto, MovieSearch, MovieInsertDto, MovieUpdateDto>
    {
        Task SetPosterAsync(int id, IFormFile file);
        Task<(byte[] Data, string ContentType)?> GetPosterAsync(int id);
    }
}
