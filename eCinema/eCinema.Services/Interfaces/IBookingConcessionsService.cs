using eCinema.Models.DTOs.Movies;
using eCinema.Models.DTOs.BookingConcessions;
using eCinema.Models.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Services.Interfaces
{
    public interface IBookingConcessionsService : ICRUDService<BookingConcessionDto, BookingConcessionSearchObject, BookingConcessionInsertDto, BookingConcessionUpdateDto>
    {
    }
}
