using eCinema.Model.Entities;
using eCinema.Models.DTOs.CinemaHalls;
using eCinema.Models.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Services.Interfaces
{
    public interface ICinemaHallService : ICRUDService<CinemaHallDto, BaseSearchObject, CinemaHallInsertDto, CinemaHallUpdateDto>
    {
    }
}
