using eCinema.Model.Entities;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models
{
    public class eCinemaDbContext : DbContext
    {
        public eCinemaDbContext(DbContextOptions<eCinemaDbContext> options)
            : base(options)
        {
        }

        public DbSet<Movie> Movies { get; set; }
        public DbSet<Genre> Genres { get; set; }
        public DbSet<MovieGenre> MovieGenres { get; set; }
        public DbSet<Actor> Actors { get; set; }
        public DbSet<MovieActor> MovieActors { get; set; }
        public DbSet<Cinema> Cinemas { get; set; }
        public DbSet<CinemaHall> CinemaHalls { get; set; }
        public DbSet<Seat> Seats { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<Movie>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Title).IsRequired().HasMaxLength(200);
                entity.Property(e => e.Description).HasMaxLength(2000);
                entity.Property(e => e.DurationMinutes).IsRequired();
                entity.Property(e => e.Language).IsRequired().HasMaxLength(50);
                entity.Property(e => e.ReleaseDate).IsRequired();
                entity.Property(e => e.Status).IsRequired();
                entity.Property(e => e.PgRating).IsRequired();
            });
           
            modelBuilder.Entity<Genre>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Name).IsRequired().HasMaxLength(100);
            });

            modelBuilder.Entity<MovieGenre>(entity =>
            {
                entity.HasKey(mg => new { mg.MovieId, mg.GenreId });

                entity.HasOne(mg => mg.Movie)
                    .WithMany(m => m.MovieGenres)
                    .HasForeignKey(mg => mg.MovieId)
                    .OnDelete(DeleteBehavior.Restrict);

                entity.HasOne(mg => mg.Genre)
                    .WithMany(g => g.MovieGenres)
                    .HasForeignKey(mg => mg.GenreId)
                    .OnDelete(DeleteBehavior.Restrict);
            });

            modelBuilder.Entity<Actor>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.FirstName).IsRequired().HasMaxLength(100);
                entity.Property(e => e.LastName).IsRequired().HasMaxLength(100);
            });

            modelBuilder.Entity<MovieActor>(entity =>
            {
                entity.HasKey(ma => new { ma.MovieId, ma.ActorId });

                entity.HasOne(ma => ma.Movie)
                    .WithMany(m => m.MovieActors)
                    .HasForeignKey(ma => ma.MovieId)
                    .OnDelete(DeleteBehavior.Restrict);

                entity.HasOne(ma => ma.Actor)
                    .WithMany(a => a.MovieActors)
                    .HasForeignKey(ma => ma.ActorId)
                    .OnDelete(DeleteBehavior.Restrict);
            });

            modelBuilder.Entity<Cinema>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Name).IsRequired().HasMaxLength(200);
                entity.Property(e => e.City).IsRequired().HasMaxLength(100);
                entity.Property(e => e.Address).IsRequired().HasMaxLength(500);
            });

            modelBuilder.Entity<CinemaHall>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Name).IsRequired().HasMaxLength(100);
                entity.Property(e => e.Capacity).IsRequired();

                entity.HasOne(ch => ch.Cinema)
                    .WithMany(c => c.CinemaHalls)
                    .HasForeignKey(ch => ch.CinemaId)
                    .OnDelete(DeleteBehavior.Restrict);
            });

            modelBuilder.Entity<Seat>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Row).IsRequired().HasMaxLength(10);
                entity.Property(e => e.Number).IsRequired();
                entity.Property(e => e.Type).IsRequired().HasMaxLength(50);

                entity.HasOne(s => s.CinemaHall)
                    .WithMany(ch => ch.Seats)
                    .HasForeignKey(s => s.CinemaHallId)
                    .OnDelete(DeleteBehavior.Restrict);
            });
        }
    }
}
