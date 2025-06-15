using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.DTOs.BookingConcessions
{
    public class BookingConcessionInsertDto
    {
        public int ConcessionId { get; set; }
        public int Quantity { get; set; }
    }
}
