using eCinema.Models.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.SearchObjects
{
    public class MovieSearch : BaseSearchObject
    {
        public string? Title { get; set; }
        public MovieStatus? Status { get; set; }
    }
}
