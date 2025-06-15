using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.DTOs.SeatTypes
{
    public class SeatTypeUpdateDto
    {
        public string? Name { get; set; }

        public decimal PriceMultiplier { get; set; }
    }
}
