using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.DTOs.Seats
{
    public class SeatDistributionDto
    {
        public int SeatTypeId { get; set; }
        public string SeatTypeName { get; set; }
        public int Count { get; set; }
    }
}
