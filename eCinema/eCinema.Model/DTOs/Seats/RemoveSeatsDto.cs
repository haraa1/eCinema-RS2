using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.DTOs.Seats
{
    public class RemoveSeatsDto
    {
        public int SeatTypeId { get; set; }
        public int NumberOfSeats { get; set; }
    }
}
