using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.SearchObjects
{
    public class BookingConcessionSearchObject : BaseSearchObject
    {
        public int? LastNMonths { get; set; }
    }
}
