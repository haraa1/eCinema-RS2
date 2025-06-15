using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.DTOs.BookingConcessions
{
    public class BookingConcessionDto
    {
        public int BookingId { get; set; }
        public int ConcessionId { get; set; }
        public string ConcessionName { get; set; }
        public int Quantity { get; set; }
        public decimal UnitPrice { get; set; }
        public decimal TotalPrice { get; set; } 
        public DateTime BookingTime { get; set; }
    }
}
