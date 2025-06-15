using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.DTOs.Seats
{
    public class AddSeatsDto
    {
        public int NumberOfSeats { get; set; }
        public int DefaultSeatTypeId { get; set; }
    }
}
