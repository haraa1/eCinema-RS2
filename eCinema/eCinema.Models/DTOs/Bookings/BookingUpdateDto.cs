using eCinema.Models.DTOs.BookingConcessions;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.DTOs.Bookings
{
    public class BookingUpdateDto
    {
        public int Id { get; set; }

        public int UserId { get; set; }
        public int ShowtimeId { get; set; }
        public DateTime BookingTime { get; set; }
        public string? DiscountCode { get; set; }
        public List<BookingConcessionUpdateDto> BookingConcessions { get; set; }
            = new List<BookingConcessionUpdateDto>();
    }
}
