using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.DTOs.TicketTypes
{
    public class TicketTypeUpdateDto
    {
        public string Name { get; set; }
        public decimal PriceModifier { get; set; }
    }
}
