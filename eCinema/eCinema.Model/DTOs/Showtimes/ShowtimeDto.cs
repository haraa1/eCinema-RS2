using eCinema.Models.DTOs.Bookings;
using eCinema.Models.DTOs.CinemaHalls;
using eCinema.Models.DTOs.Movies;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.DTOs.Showtimes
{
    public class ShowtimeDto
    {
        public int Id { get; set; }
        public DateTime StartTime { get; set; }
        public DateTime EndTime { get; set; }
        public decimal BasePrice { get; set; }

        public MovieDto Movie { get; set; }
        public CinemaHallDto CinemaHall { get; set; }
        public IEnumerable<BookingDto> Bookings { get; set; }
    }
}
