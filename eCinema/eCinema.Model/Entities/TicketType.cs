using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Sockets;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.Entities
{
    public class TicketType
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public decimal PriceModifier { get; set; }
        public ICollection<Ticket> Tickets { get; set; }
    }
}
