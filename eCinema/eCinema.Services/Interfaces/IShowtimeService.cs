using eCinema.Models.DTOs.Bookings;
using eCinema.Models.DTOs.Seats;
using eCinema.Models.DTOs.Showtimes;
using eCinema.Models.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Services.Interfaces
{
    public interface IShowtimeService : ICRUDService<ShowtimeDto, BaseSearchObject, ShowtimeInsertDto, ShowtimeUpdateDto>
    {

    }
}
