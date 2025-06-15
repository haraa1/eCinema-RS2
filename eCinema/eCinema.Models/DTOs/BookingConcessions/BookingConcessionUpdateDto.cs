using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.DTOs.BookingConcessions
{
    public class BookingConcessionUpdateDto
    {
        public int BookingId { get; set; }
        public int ConcessionId { get; set; }
        public int Quantity { get; set; }

    }
}
