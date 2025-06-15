using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models
{
    public sealed record MovieContentRow
    {
        public int MovieId { get; init; }

        public string Genres { get; init; }

        public string Actors { get; init; }
    }
}
