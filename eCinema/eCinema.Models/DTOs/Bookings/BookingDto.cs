using eCinema.Models.DTOs.BookingConcessions;
using eCinema.Models.DTOs.Showtimes;
using eCinema.Models.DTOs.Tickets;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.DTOs.Bookings
{
    public class BookingDto
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public int ShowtimeId { get; set; }
        public DateTime BookingTime { get; set; }
        public string? DiscountCode { get; set; }
        public List<TicketDto> Tickets { get; set; } = new List<TicketDto>();

        public List<BookingConcessionDto> BookingConcessions { get; set; }
            = new List<BookingConcessionDto>();
    }
}
