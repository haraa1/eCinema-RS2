using eCinema.Models.DTOs.Showtimes;
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
        public DateTime BookingTime { get; set; }
        public string? DiscountCode { get; set; }

        //public UserDto User { get; set; }
        public ShowtimeDto Showtime { get; set; }

        //public IEnumerable<TicketDto> Tickets { get; set; }
        //public IEnumerable<BookingConcessionDto> BookingConcessions { get; set; }
    }
}
