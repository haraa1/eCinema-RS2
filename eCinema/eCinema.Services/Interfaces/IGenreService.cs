using eCinema.Models.DTOs.Genres;
using eCinema.Models.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Services.Interfaces
{
    public interface IGenreService : ICRUDService<GenreDto, GenreSearch, GenreInsertDto, GenreUpdateDto>
    {
    }
}
