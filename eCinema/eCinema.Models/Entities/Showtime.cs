using eCinema.Model.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.Entities
{
    public class Showtime
    {
        public int Id { get; set; }
        public int MovieId { get; set; }
        public int CinemaHallId { get; set; }
        public DateTime StartTime { get; set; }
        public DateTime EndTime { get; set; }
        public decimal BasePrice { get; set; }

        public Movie Movie { get; set; }
        public CinemaHall CinemaHall { get; set; }
        public ICollection<Booking> Bookings { get; set; } = new List<Booking>();
    }
}
