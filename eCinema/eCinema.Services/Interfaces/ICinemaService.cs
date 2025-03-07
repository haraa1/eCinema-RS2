using eCinema.Models.DTOs.Cinemas;
using eCinema.Models.DTOs.Movies;
using eCinema.Models.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Services.Interfaces
{
    public interface ICinemaService : ICRUDService<CinemaDto, CinemaSearch, CinemaInsertDto, CinemaUpdateDto>
    {

    }
}
