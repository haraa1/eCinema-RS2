using eCinema.Model.Entities;
using eCinema.Models.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.DTOs.Movies
{
    public class MovieInsertDto
    {
        public string Title { get; set; }
        public string Description { get; set; }
        public int DurationMinutes { get; set; }
        public string Language { get; set; }
        public DateTime ReleaseDate { get; set; }
        public MovieStatus Status { get; set; }
        public PgRating PgRating { get; set; }
        public List<int> ActorIds { get; set; }
    }
}
