using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.DTOs.Seats
{
    public class UpdateSeatDistributionDto
    {
        public int TotalSeats { get; set; }
        public List<SeatDistributionUpdateDto> Distributions { get; set; } = new List<SeatDistributionUpdateDto>();
    }

    public class SeatDistributionUpdateDto
    {
        public int SeatTypeId { get; set; }
        public int Count { get; set; }
    }
}
