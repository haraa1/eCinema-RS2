using eCinema.Model.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.Entities
{
    public class Ticket
    {
        public int Id { get; set; }
        public int BookingId { get; set; }
        public int SeatId { get; set; }
        public int TicketTypeId { get; set; }
        public decimal Price { get; set; } 

        
        public Booking Booking { get; set; }
        public Seat Seat { get; set; }
        public TicketType TicketType { get; set; }
    }
}
