using CinemaApp.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Sockets;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.Entities
{
    public class Booking
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public int ShowtimeId { get; set; }
        public DateTime BookingTime { get; set; }
        public string? DiscountCode { get; set; }
        public User User { get; set; }
        public Showtime Showtime { get; set; }
        public Payment Payment { get; set; }
        public ICollection<Ticket> Tickets { get; set; } = new List<Ticket>();
        public ICollection<BookingConcession> BookingConcessions { get; set; } = new List<BookingConcession>();
    }
}
