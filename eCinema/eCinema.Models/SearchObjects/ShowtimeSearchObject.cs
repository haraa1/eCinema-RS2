using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.SearchObjects
{
    public class ShowtimeSearchObject : BaseSearchObject
    {
        public string? Title { get; set; }
        public int? CinemaId { get; set; }
    }
}
