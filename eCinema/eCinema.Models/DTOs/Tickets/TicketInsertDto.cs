using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.DTOs.Tickets
{
    public class TicketInsertDto
    {
        public int SeatId { get; set; }
        public int TicketTypeId { get; set; }
        public decimal Price { get; set; }
    }
}
