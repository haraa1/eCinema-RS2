using eCinema.Models.DTOs.Movies;
using eCinema.Models.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Services
{
    public interface IMovieService : ICRUDService<MovieDto, MovieSearch, MovieInsertDto, MovieUpdateDto>
    {
       
    }
}
