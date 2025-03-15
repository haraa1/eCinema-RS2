using eCinema.Models.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Model.Entities
{
    public class CinemaHall
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public int Capacity { get; set; }
        public int CinemaId { get; set; }

        public Cinema Cinema { get; set; }
        public ICollection<Seat> Seats { get; set; } = new List<Seat>();
        public ICollection<Showtime> Showtimes { get; set; } = new List<Showtime>();
    }
}
