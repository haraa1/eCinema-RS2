using eCinema.Model.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.Entities
{
    public class SeatType
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public decimal PriceMultiplier { get; set; }

        public ICollection<Seat> Seats { get; set; } = new List<Seat>();
    }
}
