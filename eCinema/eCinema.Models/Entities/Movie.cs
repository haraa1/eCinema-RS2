﻿using eCinema.Models.Entities;
using eCinema.Models.Enums;

namespace eCinema.Model.Entities
{
    public class Movie
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public int DurationMinutes { get; set; }
        public string Language { get; set; }
        public DateTime ReleaseDate { get; set; }
        public MovieStatus Status { get; set; }
        public PgRating PgRating { get; set; }
        public byte[]? PosterImage { get; set; }

        public ICollection<MovieGenre> MovieGenres { get; set; } = new List<MovieGenre>();
        public ICollection<MovieActor> MovieActors { get; set; } = new List<MovieActor>();
        public ICollection<Showtime> Showtimes { get; set; } = new List<Showtime>();

    }
}
