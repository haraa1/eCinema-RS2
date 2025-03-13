using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.DTOs.CinemaHalls
{
    public class CinemaHallInsertDto
    {
        public string Name { get; set; }
        public int CinemaId { get; set; }     
        public int Rows { get; set; }
        public int SeatsPerRow { get; set; }
        public int SeatTypeId { get; set; }
    }
}
