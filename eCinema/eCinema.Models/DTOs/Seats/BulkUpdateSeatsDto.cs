using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.DTOs.Seats
{
    public class BulkUpdateSeatsDto
    {
        public List<int> SeatIds { get; set; } = new List<int>();
        public int NewSeatTypeId { get; set; }
    }
}
