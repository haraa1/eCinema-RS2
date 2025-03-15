using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.Entities
{
    public class BookingConcession
    {
        public int BookingId { get; set; }
        public Booking Booking { get; set; }
        public int ConcessionId { get; set; }
        public Concession Concession { get; set; }
        public int Quantity { get; set; }
    }
}
