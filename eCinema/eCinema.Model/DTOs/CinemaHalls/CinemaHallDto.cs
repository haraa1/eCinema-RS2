using eCinema.Models.DTOs.Seats;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.DTOs.CinemaHalls
{
    public class CinemaHallDto
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public int CinemaId { get; set; }
        public int Capacity { get; set; }
        public List<SeatDto> Seats { get; set; }
    }
}
