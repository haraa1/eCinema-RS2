using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.DTOs.TicketTypes
{
    public class TicketTypeInsertDto
    {
        public string Name { get; set; }
        public decimal PriceModifier { get; set; }
    }
}
