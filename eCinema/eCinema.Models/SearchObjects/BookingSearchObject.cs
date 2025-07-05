using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.SearchObjects
{
    public class BookingSearchObject : BaseSearchObject
    {

        public int? UserId { get; set; }
        public int? ShowtimeId { get; set; }
        public string? DiscountCode { get; set; }
        public DateTime? BookingTimeFrom { get; set; }
        public DateTime? BookingTimeTo { get; set; }
    }
}
