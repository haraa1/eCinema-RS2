using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.DTOs.Seats
{
    public class SeatDto
    {
        public int Id { get; set; }
        public string Row { get; set; }
        public int Number { get; set; }
        public bool isAvailable { get; set; }
        public int SeatTypeId { get; set; }
    }
}
