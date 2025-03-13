using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.DTOs.SeatTypes
{
    public class SeatTypeDto
    {       
        public int Id { get; set; }
     
        public string? Name { get; set; }

        public decimal PriceMultiplier { get; set; }
    }
}
