using eCinema.Models.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Model.Entities
{
    public class Seat
    {
        public int Id { get; set; }
        public string Row { get; set; }
        public int Number { get; set; }
        public bool isAvailable {  get; set; }
        public int SeatTypeId { get; set; }
        public SeatType SeatType { get; set; }
        public int CinemaHallId { get; set; }

        public CinemaHall CinemaHall { get; set; }
    }
}
