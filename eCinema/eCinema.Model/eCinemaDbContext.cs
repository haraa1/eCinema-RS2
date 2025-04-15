using eCinema.Model.Entities;
using eCinema.Models.Entities;
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
        public DbSet<SeatType> SeatTypes { get; set; }
        public DbSet<Booking> Bookings { get; set; }
        public DbSet<BookingConcession> BookingConcessions { get; set; }
        public DbSet<Concession> Concessions { get; set; }
        public DbSet<Showtime> Showtime { get; set; }
        public DbSet<Ticket> Ticket { get; set; }
        public DbSet<TicketType> TicketType { get; set; }
        public DbSet<User> User { get; set; }
        public DbSet<Role> Roles { get; set; }
        public DbSet<UserRole> UserRoles { get; set; }

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

                
                entity.HasMany(e => e.Showtimes)
                   .WithOne(s => s.Movie)
                   .HasForeignKey(s => s.MovieId)
                   .OnDelete(DeleteBehavior.Restrict);
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
                    .OnDelete(DeleteBehavior.Cascade);

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
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasOne(ma => ma.Actor)
                    .WithMany(a => a.MovieActors)
                    .HasForeignKey(ma => ma.ActorId)
                    .OnDelete(DeleteBehavior.Cascade);
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
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasMany(ch => ch.Showtimes)
                   .WithOne(s => s.CinemaHall)
                   .HasForeignKey(s => s.CinemaHallId)
                   .OnDelete(DeleteBehavior.Cascade);
            });

            modelBuilder.Entity<Seat>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Row).IsRequired().HasMaxLength(10);
                entity.Property(e => e.Number).IsRequired();
                

                entity.HasOne(s => s.CinemaHall)
                    .WithMany(ch => ch.Seats)
                    .HasForeignKey(s => s.CinemaHallId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasOne(s => s.SeatType)
                    .WithMany(st => st.Seats)
                    .HasForeignKey(s => s.SeatTypeId)
                    .OnDelete(DeleteBehavior.Restrict);

            });

            modelBuilder.Entity<SeatType>(entity =>
            {
                entity.HasKey(st => st.Id);
                entity.Property(st => st.Name).IsRequired().HasMaxLength(50);
                entity.Property(st => st.PriceMultiplier).HasColumnType("decimal(18,2)").IsRequired();

                
                entity.HasData(
                    new SeatType { Id = 1, Name = "Standard", PriceMultiplier = 1.0m },
                    new SeatType { Id = 2, Name = "Love Seat", PriceMultiplier = 1.0m },
                    new SeatType { Id = 3, Name = "VIP", PriceMultiplier = 1.5m }
                );
            });

            modelBuilder.Entity<User>(entity =>
            {
                entity.HasKey(e => e.Id);

                entity.Property(e => e.UserName).IsRequired().HasMaxLength(50);
                entity.Property(e => e.Email).IsRequired().HasMaxLength(100);
                entity.Property(e => e.PasswordHash).IsRequired();
                entity.Property(e => e.PasswordSalt).IsRequired();
                entity.Property(e => e.PhoneNumber).HasMaxLength(20);
                entity.Property(e => e.CreatedAt).IsRequired();
            });

            modelBuilder.Entity<Showtime>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.StartTime).IsRequired();
                entity.Property(e => e.EndTime).IsRequired();
                entity.Property(e => e.BasePrice).IsRequired().HasColumnType("decimal(18,2)");

                entity.HasOne(s => s.Movie)
                    .WithMany(m => m.Showtimes)
                    .HasForeignKey(s => s.MovieId)
                    .OnDelete(DeleteBehavior.Restrict);

                entity.HasOne(s => s.CinemaHall)
                    .WithMany(ch => ch.Showtimes)
                    .HasForeignKey(s => s.CinemaHallId)
                    .OnDelete(DeleteBehavior.Restrict);
            });

            modelBuilder.Entity<Booking>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.BookingTime).IsRequired();
                entity.Property(e => e.DiscountCode).HasMaxLength(10);

                entity.HasOne(b => b.User)
                    .WithMany(u => u.Bookings)
                    .HasForeignKey(b => b.UserId)
                    .OnDelete(DeleteBehavior.Restrict);

                entity.HasOne(b => b.Showtime)
                    .WithMany(s => s.Bookings)
                    .HasForeignKey(b => b.ShowtimeId)
                    .OnDelete(DeleteBehavior.Restrict);
              
            });
            modelBuilder.Entity<Ticket>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Price).IsRequired().HasColumnType("decimal(18,2)");

                entity.HasOne(t => t.Booking)
                    .WithMany(b => b.Tickets)
                    .HasForeignKey(t => t.BookingId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasOne(t => t.Seat)
                    .WithMany()
                    .HasForeignKey(t => t.SeatId)
                    .OnDelete(DeleteBehavior.Restrict);

                entity.HasOne(t => t.TicketType)
                    .WithMany(tt => tt.Tickets)
                    .HasForeignKey(t => t.TicketTypeId)
                    .OnDelete(DeleteBehavior.Restrict);
            });

            modelBuilder.Entity<TicketType>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Name).IsRequired().HasMaxLength(50);
                entity.Property(e => e.PriceModifier).IsRequired().HasColumnType("decimal(18,2)");
            });

            modelBuilder.Entity<Concession>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Name).IsRequired().HasMaxLength(100);
                entity.Property(e => e.Price).IsRequired().HasColumnType("decimal(18,2)");
                entity.Property(e => e.Description).HasMaxLength(500);
            });

            modelBuilder.Entity<BookingConcession>(entity =>
            {
                entity.HasKey(bc => new { bc.BookingId, bc.ConcessionId });
                entity.Property(bc => bc.Quantity).IsRequired();

                entity.HasOne(bc => bc.Booking)
                    .WithMany(b => b.BookingConcessions)
                    .HasForeignKey(bc => bc.BookingId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasOne(bc => bc.Concession)
                    .WithMany()
                    .HasForeignKey(bc => bc.ConcessionId)
                    .OnDelete(DeleteBehavior.Restrict);
            });

            modelBuilder.Entity<Role>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Name)
                      .IsRequired()
                      .HasMaxLength(50);

            entity.HasData(
                    new Role { Id = 1, Name = "Admin"},
                    new Role { Id = 2, Name = "User"}
                );
            });

            modelBuilder.Entity<UserRole>(entity =>
            {
                entity.HasKey(e => e.Id);

                entity.HasOne(ur => ur.User)
                      .WithMany(u => u.UserRoles)
                      .HasForeignKey(ur => ur.UserId)
                      .OnDelete(DeleteBehavior.Cascade);

                entity.HasOne(ur => ur.Role)
                      .WithMany(r => r.UserRoles)
                      .HasForeignKey(ur => ur.RoleId)
                      .OnDelete(DeleteBehavior.Cascade);
            });



        }
    }
}
