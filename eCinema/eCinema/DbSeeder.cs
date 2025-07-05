using CinemaApp.Domain.Entities;
using eCinema.Model.Entities;
using eCinema.Models.Entities;
using eCinema.Models;
using eCinema.Services.Services;
using Microsoft.EntityFrameworkCore;
using System.Reflection;

namespace eCinema.Data.Seeding
{
    public static class DataSeeder
    {
        public static async Task SeedAsync(eCinemaDbContext context, string webRootPath)
        {
            if (await context.Movies.AnyAsync())
            {
                return;
            }

            var genres = await SeedGenresAsync(context);
            var actors = await SeedActorsAsync(context);
            var cinemas = await SeedCinemasAndHallsAsync(context);
            var users = await SeedUsersAsync(context, webRootPath);
            var concessions = await SeedConcessionsAsync(context);
            var discounts = await SeedDiscountsAsync(context);
            var movies = await SeedMoviesAsync(context, genres, actors, webRootPath);
            var showtimes = await SeedShowtimesAsync(context, movies, cinemas);

            await SeedBookingsAndRelatedDataAsync(context, showtimes, users, concessions, discounts);
        }

        private static async Task<List<Genre>> SeedGenresAsync(eCinemaDbContext context)
        {
            if (await context.Genres.AnyAsync()) return await context.Genres.ToListAsync();
            var genres = new List<Genre>
            {
                new Genre { Name = "Akcija" }, new Genre { Name = "Komedija" }, new Genre { Name = "Drama" },
                new Genre { Name = "Naučna fantastika" }, new Genre { Name = "Horor" }, new Genre { Name = "Triler" },
                new Genre { Name = "Avantura" }, new Genre { Name = "Biografija" }, new Genre { Name = "Historija" },
                new Genre { Name = "Kriminalistički" }, new Genre { Name = "Animacija" }, new Genre { Name = "Porodični" }
            };
            await context.Genres.AddRangeAsync(genres);
            await context.SaveChangesAsync();
            return genres;
        }

        private static async Task<List<Actor>> SeedActorsAsync(eCinemaDbContext context)
        {
            if (await context.Actors.AnyAsync()) return await context.Actors.ToListAsync();
            var actors = new List<Actor>
            {
                new Actor { FirstName = "Tom", LastName = "Hanks" }, new Actor { FirstName = "Scarlett", LastName = "Johansson" },
                new Actor { FirstName = "Leonardo", LastName = "DiCaprio" }, new Actor { FirstName = "Zendaya", LastName = "Coleman" },
                new Actor { FirstName = "Dwayne", LastName = "Johnson" }, new Actor { FirstName = "John", LastName = "Cena"},
                new Actor { FirstName = "Cillian", LastName = "Murphy" }, new Actor { FirstName = "Emily", LastName = "Blunt" },
                new Actor { FirstName = "Matt", LastName = "Damon" }, new Actor { FirstName = "Tim", LastName = "Robbins" },
                new Actor { FirstName = "Morgan", LastName = "Freeman" }
            };
            await context.Actors.AddRangeAsync(actors);
            await context.SaveChangesAsync();
            return actors;
        }

        private static async Task<List<Cinema>> SeedCinemasAndHallsAsync(eCinemaDbContext context)
        {
            if (await context.Cinemas.AnyAsync()) return await context.Cinemas.Include(c => c.CinemaHalls).ThenInclude(ch => ch.Seats).ToListAsync();

            var cinemas = new List<Cinema>
            {
                new Cinema
                {
                    Name = "eCinema City Centar", City = "Metropolis", Address = "Glavna ulica 123",
                    CinemaHalls = new List<CinemaHall>
                    {
                        new CinemaHall { Name = "Sala 1", Capacity = 150 },
                        new CinemaHall { Name = "Sala 2 (VIP)", Capacity = 50 },
                        new CinemaHall { Name = "Sala 3", Capacity = 150 }
                    }
                },
                new Cinema
                {
                    Name = "eCinema Predgrađe", City = "Metropolis", Address = "Hrastova avenija 456",
                    CinemaHalls = new List<CinemaHall>
                    {
                        new CinemaHall { Name = "Velika sala", Capacity = 200 },
                        new CinemaHall { Name = "Ugodni kutak", Capacity = 75 }
                    }
                },
                new Cinema
                {
                    Name = "eCinema Gotham Plaza", City = "Gotham", Address = "Sjena ulica 77",
                    CinemaHalls = new List<CinemaHall>
                    {
                        new CinemaHall { Name = "Dvorana Pravde", Capacity = 250 },
                        new CinemaHall { Name = "Dvorana Tame", Capacity = 100 }
                    }
                }
            };
            await context.Cinemas.AddRangeAsync(cinemas);
            await context.SaveChangesAsync();

            var halls = await context.CinemaHalls.ToListAsync();
            var seatTypes = await context.SeatTypes.ToListAsync();
            var standardSeatType = seatTypes.First(st => st.Name == "Standard");
            var vipSeatType = seatTypes.First(st => st.Name == "VIP");

            foreach (var hall in halls)
            {
                var seats = new List<Seat>();
                char row = 'A';
                int numRows = hall.Name.Contains("Velika") || hall.Name.Contains("Pravde") ? 12 : 10;
                int numSeatsPerRow = hall.Name.Contains("Velika") || hall.Name.Contains("Pravde") ? 18 : 15;

                for (int i = 0; i < numRows; i++)
                {
                    for (int j = 1; j <= numSeatsPerRow; j++)
                    {
                        seats.Add(new Seat
                        {
                            Row = row.ToString(),
                            Number = j,
                            CinemaHallId = hall.Id,
                            SeatTypeId = hall.Name.Contains("VIP") ? vipSeatType.Id : standardSeatType.Id
                        });
                    }
                    row++;
                }
                await context.Seats.AddRangeAsync(seats);
            }
            await context.SaveChangesAsync();

            return await context.Cinemas.Include(c => c.CinemaHalls).ThenInclude(ch => ch.Seats).ToListAsync();
        }

        private static async Task<List<User>> SeedUsersAsync(eCinemaDbContext context, string webRootPath)
        {
            if (await context.User.AnyAsync()) return await context.User.ToListAsync();

            byte[]? profilePictureBytes = null;
            try
            {
                string imagePath = Path.Combine(webRootPath, "images", "oppenheimer.jpg");
                if (File.Exists(imagePath))
                {
                    profilePictureBytes = await File.ReadAllBytesAsync(imagePath);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Nije moguće učitati sliku profila za popunjavanje baze: {ex.Message}");
            }

            var adminRole = await context.Roles.FirstAsync(r => r.Name == "Admin");
            var userRole = await context.Roles.FirstAsync(r => r.Name == "User");

            var adminSalt = UserService.GenerateSalt();
            var userSalt = UserService.GenerateSalt();

            var users = new List<User>
            {
                new User
                {
                    FullName = "Admin Korisnik", UserName = "admin", Email = "admin@ecinema.com",
                    PasswordHash = UserService.GenerateHash(adminSalt, "admin123"),
                    PasswordSalt = adminSalt,
                    PhoneNumber = "111-222-333", CreatedAt = DateTime.UtcNow,
                    ProfilePicture = profilePictureBytes,
                    UserRoles = new List<UserRole> { new UserRole { RoleId = adminRole.Id } }
                },
                new User
                {
                    FullName = "Standardni Korisnik", UserName = "user", Email = "user@ecinema.com",
                    PasswordHash = UserService.GenerateHash(userSalt, "user123"),
                    PasswordSalt = userSalt,
                    PhoneNumber = "444-555-666", CreatedAt = DateTime.UtcNow,
                    ProfilePicture = profilePictureBytes,
                    UserRoles = new List<UserRole> { new UserRole { RoleId = userRole.Id } }
                }
            };
            await context.User.AddRangeAsync(users);
            await context.SaveChangesAsync();
            return users;
        }

        private static async Task<List<Concession>> SeedConcessionsAsync(eCinemaDbContext context)
        {
            if (await context.Concessions.AnyAsync()) return await context.Concessions.ToListAsync();
            var concessions = new List<Concession>
            {
                new Concession { Name = "Velike kokice", Price = 8.50m, Description = "Svježe iskokane kokice." },
                new Concession { Name = "Srednji sok", Price = 5.00m, Description = "Gazirano piće po vašem izboru." },
                new Concession { Name = "Kutija slatkiša", Price = 4.25m, Description = "Kutija popularnih filmskih slatkiša." },
                new Concession { Name = "Nachos sa sirom", Price = 7.75m, Description = "Hrskavi tortilja čips s toplim umakom od sira." }
            };
            await context.Concessions.AddRangeAsync(concessions);
            await context.SaveChangesAsync();
            return concessions;
        }

        private static async Task<List<Discount>> SeedDiscountsAsync(eCinemaDbContext context)
        {
            if (await context.Discounts.AnyAsync()) return await context.Discounts.ToListAsync();
            var discounts = new List<Discount>
            {
                new Discount { Code = "LJETO20", DiscountPercentage = 20.00m },
                new Discount { Code = "DOBRODOSLI10", DiscountPercentage = 10.00m },
                new Discount { Code = "UTORAK50", DiscountPercentage = 50.00m }
            };
            await context.Discounts.AddRangeAsync(discounts);
            await context.SaveChangesAsync();
            return discounts;
        }

        private static async Task<List<Movie>> SeedMoviesAsync(eCinemaDbContext context, List<Genre> genres, List<Actor> actors, string webRootPath)
        {
            if (await context.Movies.AnyAsync()) return await context.Movies.ToListAsync();

            byte[]? oppenheimerPoster = null;
            byte[]? shawshankPoster = null;

            try
            {
                string oppenheimerPath = Path.Combine(webRootPath, "images", "oppenheimer.jpg");
                if (File.Exists(oppenheimerPath))
                {
                    oppenheimerPoster = await File.ReadAllBytesAsync(oppenheimerPath);
                }

                string shawshankPath = Path.Combine(webRootPath, "images", "shawshank.jpg");
                if (File.Exists(shawshankPath))
                {
                    shawshankPoster = await File.ReadAllBytesAsync(shawshankPath);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Nije moguće učitati slike za popunjavanje baze: {ex.Message}");
            }

            var movies = new List<Movie>
            {
                new Movie
                {
                    Title = "Oppenheimer", Description = "Priča o američkom naučniku J. Robertu Oppenheimeru i njegovoj ulozi u razvoju atomske bombe.", DurationMinutes = 180,
                    Language = "Engleski", ReleaseDate = new DateTime(2023, 7, 21), Status = (Models.Enums.MovieStatus)1, PgRating = (Models.Enums.PgRating)3,
                    PosterImage = oppenheimerPoster,
                    MovieGenres = new List<MovieGenre>
                    {
                        new MovieGenre { Genre = genres.First(g => g.Name == "Biografija") },
                        new MovieGenre { Genre = genres.First(g => g.Name == "Drama") },
                        new MovieGenre { Genre = genres.First(g => g.Name == "Historija") }
                    },
                    MovieActors = new List<MovieActor>
                    {
                        new MovieActor { Actor = actors.First(a => a.FirstName == "Cillian") },
                        new MovieActor { Actor = actors.First(a => a.FirstName == "Emily") },
                        new MovieActor { Actor = actors.First(a => a.FirstName == "Matt") }
                    }
                },
                new Movie
                {
                    Title = "Iskupljenje u Shawshanku", Description = "Tokom niza godina, dva zatvorenika sklapaju prijateljstvo, tražeći utjehu i, na kraju, iskupljenje kroz osnovnu suosjećajnost.", DurationMinutes = 142,
                    Language = "Engleski", ReleaseDate = new DateTime(1994, 9, 23), Status = (Models.Enums.MovieStatus)1, PgRating = (Models.Enums.PgRating)3,
                    PosterImage = shawshankPoster,
                    MovieGenres = new List<MovieGenre>
                    {
                        new MovieGenre { Genre = genres.First(g => g.Name == "Drama") }
                    },
                    MovieActors = new List<MovieActor>
                    {
                        new MovieActor { Actor = actors.First(a => a.FirstName == "Tim") },
                        new MovieActor { Actor = actors.First(a => a.FirstName == "Morgan") }
                    }
                },
                new Movie
                {
                    Title = "Početak", Description = "Lopov koji krade korporativne tajne koristeći tehnologiju dijeljenja snova dobija suprotan zadatak: da usadi ideju u um direktora kompanije.", DurationMinutes = 148,
                    Language = "Engleski", ReleaseDate = new DateTime(2010, 7, 16), Status = (Models.Enums.MovieStatus)1, PgRating = (Models.Enums.PgRating)2,
                    PosterImage = oppenheimerPoster,
                    MovieGenres = new List<MovieGenre>
                    {
                        new MovieGenre { Genre = genres.First(g => g.Name == "Akcija") },
                        new MovieGenre { Genre = genres.First(g => g.Name == "Avantura") },
                        new MovieGenre { Genre = genres.First(g => g.Name == "Naučna fantastika") }
                    },
                    MovieActors = new List<MovieActor>
                    {
                        new MovieActor { Actor = actors.First(a => a.FirstName == "Leonardo") },
                        new MovieActor { Actor = actors.First(a => a.FirstName == "Tom") },
                        new MovieActor { Actor = actors.First(a => a.FirstName == "Cillian") }
                    }
                },
                new Movie
                {
                    Title = "Krstarenje džunglom", Description = "Zasnovano na vožnji u tematskom parku Disneyland gdje mali riječni brod vodi grupu putnika kroz džunglu punu opasnih životinja i gmizavaca, ali sa natprirodnim elementom.", DurationMinutes = 127,
                    Language = "Bosanski", ReleaseDate = new DateTime(2021, 7, 30), Status = (Models.Enums.MovieStatus)1, PgRating = (Models.Enums.PgRating)2,
                    PosterImage = shawshankPoster,
                    MovieGenres = new List<MovieGenre>
                    {
                        new MovieGenre { Genre = genres.First(g => g.Name == "Avantura") },
                        new MovieGenre { Genre = genres.First(g => g.Name == "Komedija") },
                        new MovieGenre { Genre = genres.First(g => g.Name == "Porodični") }
                    },
                    MovieActors = new List<MovieActor>
                    {
                        new MovieActor { Actor = actors.First(a => a.FirstName == "Dwayne") },
                        new MovieActor { Actor = actors.First(a => a.FirstName == "Emily") }
                    }
                },
                new Movie
                {
                    Title = "Forrest Gump", Description = "Historija Sjedinjenih Američkih Država od 1950-ih do 70-ih godina prikazana je iz perspektive čovjeka iz Alabame sa IQ-om od 75, koji želi da se ponovo spoji sa svojom simpatijom iz djetinjstva.", DurationMinutes = 142,
                    Language = "Engleski", ReleaseDate = new DateTime(1994, 7, 6), Status = (Models.Enums.MovieStatus)1, PgRating = (Models.Enums.PgRating)2,
                    PosterImage = oppenheimerPoster,
                    MovieGenres = new List<MovieGenre>
                    {
                        new MovieGenre { Genre = genres.First(g => g.Name == "Drama") },
                        new MovieGenre { Genre = genres.First(g => g.Name == "Komedija") }
                    },
                    MovieActors = new List<MovieActor>
                    {
                        new MovieActor { Actor = actors.First(a => a.FirstName == "Tom") }
                    }
                },
                new Movie
                {
                    Title = "Mračni vitez", Description = "Kada prijetnja poznata kao Joker izazove haos i pustoš među stanovnicima Gothama, Batman se mora suočiti s jednim od najvećih psiholoških i fizičkih testova svoje sposobnosti da se bori protiv nepravde.", DurationMinutes = 152,
                    Language = "Engleski", ReleaseDate = new DateTime(2008, 7, 18), Status = (Models.Enums.MovieStatus)0, PgRating = (Models.Enums.PgRating)2,
                    PosterImage = shawshankPoster,
                    MovieGenres = new List<MovieGenre>
                    {
                        new MovieGenre { Genre = genres.First(g => g.Name == "Akcija") },
                        new MovieGenre { Genre = genres.First(g => g.Name == "Kriminalistički") },
                        new MovieGenre { Genre = genres.First(g => g.Name == "Drama") }
                    },
                    MovieActors = new List<MovieActor>
                    {
                        new MovieActor { Actor = actors.First(a => a.FirstName == "Cillian") },
                        new MovieActor { Actor = actors.First(a => a.FirstName == "Morgan") }
                    }
                },
                new Movie
                {
                    Title = "Dina: Drugi dio", Description = "Paul Atreides se udružuje sa Chani i Fremenima dok je na ratnom putu osvete protiv zavjerenika koji su uništili njegovu porodicu. Suočen s izborom između ljubavi svog života i sudbine poznate vaseljene, nastoji spriječiti užasnu budućnost koju samo on može predvidjeti.", DurationMinutes = 166,
                    Language = "Engleski", ReleaseDate = new DateTime(2024, 3, 1), Status = (Models.Enums.MovieStatus)0, PgRating = (Models.Enums.PgRating)2,
                    PosterImage = oppenheimerPoster,
                    MovieGenres = new List<MovieGenre>
                    {
                        new MovieGenre { Genre = genres.First(g => g.Name == "Avantura") },
                        new MovieGenre { Genre = genres.First(g => g.Name == "Drama") },
                        new MovieGenre { Genre = genres.First(g => g.Name == "Naučna fantastika") }
                    },
                    MovieActors = new List<MovieActor>
                    {
                        new MovieActor { Actor = actors.First(a => a.FirstName == "Zendaya") },
                        new MovieActor { Actor = actors.First(a => a.FirstName == "Tim") }
                    }
                },
                new Movie
                {
                    Title = "Metropolis: The Future City",
                    Description = "In a futuristic city sharply divided between the working class and the city planners, the son of the city's master falls in love with a prophetic working-class figure.",
                    DurationMinutes = 153,
                    Language = "Engleski",
                    ReleaseDate = DateTime.Today.AddDays(15),
                    Status = (Models.Enums.MovieStatus)0,
                    PgRating = (Models.Enums.PgRating)2,
                    PosterImage = oppenheimerPoster,
                    MovieGenres = new List<MovieGenre>
                    {
                        new MovieGenre { Genre = genres.First(g => g.Name == "Naučna fantastika") },
                        new MovieGenre { Genre = genres.First(g => g.Name == "Drama") }
                    },
                    MovieActors = new List<MovieActor>
                    {
                        new MovieActor { Actor = actors.First(a => a.FirstName == "Zendaya") },
                        new MovieActor { Actor = actors.First(a => a.FirstName == "Tom") }
                    }
                },
                new Movie
                {
                    Title = "Gotham's Shadow",
                    Description = "A retired vigilante is forced back into action to protect his city from a new, ruthless gang that has taken over the streets of Gotham.",
                    DurationMinutes = 135,
                    Language = "Engleski",
                    ReleaseDate = new DateTime(2022, 5, 20),
                    Status = (Models.Enums.MovieStatus)1,
                    PgRating = (Models.Enums.PgRating)3,
                    PosterImage = shawshankPoster,
                    MovieGenres = new List<MovieGenre>
                    {
                        new MovieGenre { Genre = genres.First(g => g.Name == "Akcija") },
                        new MovieGenre { Genre = genres.First(g => g.Name == "Kriminalistički") },
                        new MovieGenre { Genre = genres.First(g => g.Name == "Triler") }
                    },
                    MovieActors = new List<MovieActor>
                    {
                        new MovieActor { Actor = actors.First(a => a.FirstName == "Morgan") },
                        new MovieActor { Actor = actors.First(a => a.FirstName == "John") }
                    }
                }
            };
            await context.Movies.AddRangeAsync(movies);
            await context.SaveChangesAsync();
            return movies;
        }

        private static async Task<List<Showtime>> SeedShowtimesAsync(eCinemaDbContext context, List<Movie> movies, List<Cinema> cinemas)
        {
            if (await context.Showtime.AnyAsync()) return await context.Showtime.ToListAsync();

            var newShowtimes = new List<Showtime>();

            var cityCenter = cinemas.First(c => c.Name == "eCinema City Centar");
            var cityCenterHall1 = cityCenter.CinemaHalls.First(h => h.Name == "Sala 1");
            var cityCenterVipHall = cityCenter.CinemaHalls.First(h => h.Name == "Sala 2 (VIP)");
            var cityCenterHall3 = cityCenter.CinemaHalls.First(h => h.Name == "Sala 3");

            var suburbia = cinemas.First(c => c.Name == "eCinema Predgrađe");
            var suburbiaBigHall = suburbia.CinemaHalls.First(h => h.Name == "Velika sala");

            var gotham = cinemas.First(c => c.Name == "eCinema Gotham Plaza");
            var gothamJusticeHall = gotham.CinemaHalls.First(h => h.Name == "Dvorana Pravde");
            var gothamDarknessHall = gotham.CinemaHalls.First(h => h.Name == "Dvorana Tame");

            var oppenheimer = movies.First(m => m.Title == "Oppenheimer");
            var shawshank = movies.First(m => m.Title == "Iskupljenje u Shawshanku");
            var inception = movies.First(m => m.Title == "Početak");
            var dune = movies.First(m => m.Title == "Dina: Drugi dio");

            var metropolisFutureMovie = movies.First(m => m.Title == "Metropolis: The Future City");
            var gothamNowShowingMovie = movies.First(m => m.Title == "Gotham's Shadow");
            for (int i = 1; i <= 30; i++)
            {
                var currentDay = DateTime.Today.AddDays(i);

                newShowtimes.Add(new Showtime
                {
                    MovieId = oppenheimer.Id,
                    CinemaHallId = cityCenterHall1.Id,
                    StartTime = currentDay.AddHours(17),
                    EndTime = currentDay.AddHours(17).AddMinutes(oppenheimer.DurationMinutes),
                    BasePrice = 12.00m
                });

                newShowtimes.Add(new Showtime
                {
                    MovieId = inception.Id,
                    CinemaHallId = suburbiaBigHall.Id,
                    StartTime = currentDay.AddHours(20),
                    EndTime = currentDay.AddHours(20).AddMinutes(inception.DurationMinutes),
                    BasePrice = 11.50m
                });

                newShowtimes.Add(new Showtime
                {
                    MovieId = dune.Id,
                    CinemaHallId = gothamJusticeHall.Id,
                    StartTime = currentDay.AddHours(21),
                    EndTime = currentDay.AddHours(21).AddMinutes(dune.DurationMinutes),
                    BasePrice = 14.00m
                });
                newShowtimes.Add(new Showtime
                {
                    MovieId = gothamNowShowingMovie.Id,
                    CinemaHallId = gothamDarknessHall.Id,
                    StartTime = currentDay.AddHours(19).AddMinutes(30),
                    EndTime = currentDay.AddHours(19).AddMinutes(30).AddMinutes(gothamNowShowingMovie.DurationMinutes),
                    BasePrice = 13.50m
                });
                if (i >= 15)
                {
                    newShowtimes.Add(new Showtime
                    {
                        MovieId = metropolisFutureMovie.Id,
                        CinemaHallId = cityCenterHall3.Id,
                        StartTime = currentDay.AddHours(20).AddMinutes(30),
                        EndTime = currentDay.AddHours(20).AddMinutes(30).AddMinutes(metropolisFutureMovie.DurationMinutes),
                        BasePrice = 13.00m
                    });
                }
                if (currentDay.DayOfWeek == DayOfWeek.Friday)
                {
                    newShowtimes.Add(new Showtime
                    {
                        MovieId = shawshank.Id,
                        CinemaHallId = cityCenterVipHall.Id,
                        StartTime = currentDay.AddHours(21).AddMinutes(30),
                        EndTime = currentDay.AddHours(21).AddMinutes(30).AddMinutes(shawshank.DurationMinutes),
                        BasePrice = 25.00m
                    });
                }
            }
            await context.Showtime.AddRangeAsync(newShowtimes);
            await context.SaveChangesAsync();
            return newShowtimes;
        }

        private static async Task SeedBookingsAndRelatedDataAsync(eCinemaDbContext context, List<Showtime> showtimes, List<User> users, List<Concession> concessions, List<Discount> discounts)
        {
            if (await context.Bookings.AnyAsync()) return;

            var ticketTypes = await context.TicketType.ToListAsync();
            var adultTicketType = ticketTypes.First(tt => tt.Name == "Adult").Id;

            var regularUser = users.First(u => u.UserName == "user");
            var userShowtime = showtimes.FirstOrDefault(s => s.Movie.Title == "Oppenheimer");
            if (userShowtime != null)
            {
                var userHallSeats = await context.Seats.Where(s => s.CinemaHallId == userShowtime.CinemaHallId).ToListAsync();

                var userBooking = new Booking
                {
                    UserId = regularUser.Id,
                    ShowtimeId = userShowtime.Id,
                    BookingTime = DateTime.UtcNow,
                    AppliedDiscountId = discounts.First(d => d.Code == "DOBRODOSLI10").Id,
                    BookingConcessions = new List<BookingConcession>
                    {
                        new BookingConcession { ConcessionId = concessions.First(c => c.Name == "Velike kokice").Id, Quantity = 1 },
                        new BookingConcession { ConcessionId = concessions.First(c => c.Name == "Srednji sok").Id, Quantity = 2 }
                    },
                    Tickets = new List<Ticket>
                    {
                        new Ticket { SeatId = userHallSeats.First(s => s.Row == "E" && s.Number == 7).Id, TicketTypeId = adultTicketType, Price = userShowtime.BasePrice },
                        new Ticket { SeatId = userHallSeats.First(s => s.Row == "E" && s.Number == 8).Id, TicketTypeId = adultTicketType, Price = userShowtime.BasePrice }
                    }
                };
                await AddBookingWithPaymentAsync(context, userBooking);
            }

            var adminUser = users.First(u => u.UserName == "admin");
            var adminShowtime = showtimes.FirstOrDefault(s => s.Movie.Title == "Dina: Drugi dio");
            if (adminShowtime != null)
            {
                var adminHallSeats = await context.Seats.Where(s => s.CinemaHallId == adminShowtime.CinemaHallId).ToListAsync();

                var adminBooking = new Booking
                {
                    UserId = adminUser.Id,
                    ShowtimeId = adminShowtime.Id,
                    BookingTime = DateTime.UtcNow.AddMinutes(-30),
                    AppliedDiscountId = discounts.First(d => d.Code == "LJETO20").Id,
                    BookingConcessions = new List<BookingConcession>
                    {
                        new BookingConcession { ConcessionId = concessions.First(c => c.Name == "Nachos sa sirom").Id, Quantity = 2 }
                    },
                    Tickets = new List<Ticket>
                    {
                        new Ticket { SeatId = adminHallSeats.First(s => s.Row == "C" && s.Number == 5).Id, TicketTypeId = adultTicketType, Price = adminShowtime.BasePrice },
                        new Ticket { SeatId = adminHallSeats.First(s => s.Row == "C" && s.Number == 6).Id, TicketTypeId = adultTicketType, Price = adminShowtime.BasePrice }
                    }
                };
                await AddBookingWithPaymentAsync(context, adminBooking);
            }

            // START: ADDED FINISHED BOOKINGS FOR PREVIOUS MONTHS
            var inceptionMovie = await context.Movies.FirstAsync(m => m.Title == "Početak");
            var shawshankMovie = await context.Movies.FirstAsync(m => m.Title == "Iskupljenje u Shawshanku");
            var historicShowtimeHall = await context.CinemaHalls.Include(h => h.Seats).FirstAsync(h => h.Name == "Sala 1");
            var historicHallSeats = historicShowtimeHall.Seats.ToList();

            // --- January Booking ---
            var janShowtime = new Showtime
            {
                Movie = inceptionMovie,
                CinemaHall = historicShowtimeHall,
                StartTime = new DateTime(DateTime.Now.Year, 1, 15, 19, 0, 0, DateTimeKind.Utc),
                EndTime = new DateTime(DateTime.Now.Year, 1, 15, 19, 0, 0, DateTimeKind.Utc).AddMinutes(inceptionMovie.DurationMinutes),
                BasePrice = 10.00m
            };
            context.Showtime.Add(janShowtime);

            var janBooking = new Booking
            {
                User = regularUser,
                Showtime = janShowtime,
                BookingTime = janShowtime.StartTime.AddDays(-3),
                Tickets = new List<Ticket>
                {
                    new Ticket { SeatId = historicHallSeats.First(s => s.Row == "A" && s.Number == 1).Id, TicketTypeId = adultTicketType, Price = janShowtime.BasePrice },
                    new Ticket { SeatId = historicHallSeats.First(s => s.Row == "A" && s.Number == 2).Id, TicketTypeId = adultTicketType, Price = janShowtime.BasePrice }
                }
            };
            await AddBookingWithPaymentAsync(context, janBooking);

            // --- February Booking ---
            var febShowtime = new Showtime
            {
                Movie = shawshankMovie,
                CinemaHall = historicShowtimeHall,
                StartTime = new DateTime(DateTime.Now.Year, 2, 20, 20, 30, 0, DateTimeKind.Utc),
                EndTime = new DateTime(DateTime.Now.Year, 2, 20, 20, 30, 0, DateTimeKind.Utc).AddMinutes(shawshankMovie.DurationMinutes),
                BasePrice = 11.00m
            };
            context.Showtime.Add(febShowtime);

            var febBooking = new Booking
            {
                User = adminUser,
                Showtime = febShowtime,
                BookingTime = febShowtime.StartTime.AddDays(-1),
                AppliedDiscountId = discounts.First(d => d.Code == "DOBRODOSLI10").Id,
                BookingConcessions = new List<BookingConcession>
                {
                    new BookingConcession { ConcessionId = concessions.First(c => c.Name == "Velike kokice").Id, Quantity = 1 }
                },
                Tickets = new List<Ticket>
                {
                    new Ticket { SeatId = historicHallSeats.First(s => s.Row == "B" && s.Number == 5).Id, TicketTypeId = adultTicketType, Price = febShowtime.BasePrice }
                }
            };
            await AddBookingWithPaymentAsync(context, febBooking);

            // --- March Booking ---
            var marShowtime = new Showtime
            {
                Movie = inceptionMovie,
                CinemaHall = historicShowtimeHall,
                StartTime = new DateTime(DateTime.Now.Year, 3, 10, 18, 0, 0, DateTimeKind.Utc),
                EndTime = new DateTime(DateTime.Now.Year, 3, 10, 18, 0, 0, DateTimeKind.Utc).AddMinutes(inceptionMovie.DurationMinutes),
                BasePrice = 10.50m
            };
            context.Showtime.Add(marShowtime);

            var marBooking = new Booking
            {
                User = regularUser,
                Showtime = marShowtime,
                BookingTime = marShowtime.StartTime.AddHours(-24),
                Tickets = new List<Ticket>
                {
                    new Ticket { SeatId = historicHallSeats.First(s => s.Row == "G" && s.Number == 10).Id, TicketTypeId = adultTicketType, Price = marShowtime.BasePrice },
                    new Ticket { SeatId = historicHallSeats.First(s => s.Row == "G" && s.Number == 11).Id, TicketTypeId = adultTicketType, Price = marShowtime.BasePrice },
                    new Ticket { SeatId = historicHallSeats.First(s => s.Row == "G" && s.Number == 12).Id, TicketTypeId = adultTicketType, Price = marShowtime.BasePrice }
                }
            };
            await AddBookingWithPaymentAsync(context, marBooking);
            // END: ADDED FINISHED BOOKINGS

            await context.SaveChangesAsync();
        }

        private static async Task AddBookingWithPaymentAsync(eCinemaDbContext context, Booking booking)
        {
            decimal ticketsTotal = booking.Tickets.Sum(t => t.Price);

            decimal concessionTotal = 0;
            if (booking.BookingConcessions != null)
            {
                foreach (var bc in booking.BookingConcessions)
                {
                    var concession = await context.Concessions.FindAsync(bc.ConcessionId);
                    if (concession != null)
                    {
                        concessionTotal += concession.Price * bc.Quantity;
                    }
                }
            }

            decimal totalBeforeDiscount = ticketsTotal + concessionTotal;
            decimal totalAmount = totalBeforeDiscount;

            if (booking.AppliedDiscountId.HasValue)
            {
                var discount = (await context.Discounts.FindAsync(booking.AppliedDiscountId))?.DiscountPercentage ?? 0;
                totalAmount = totalBeforeDiscount * (1 - (discount / 100));
            }

            long amountInPfennig = (long)(totalAmount * 100);

            booking.Payment = new Payment
            {
                Amount = amountInPfennig,
                Currency = "bam",
                Status = (CinemaApp.Domain.Entities.PaymentStatus)PaymentStatus.Uspješno,
                StripePaymentIntentId = $"pi_seed_placeholder_{Guid.NewGuid()}",
                CreatedAt = DateTime.UtcNow,
                SucceededAt = DateTime.UtcNow
            };

            await context.Bookings.AddAsync(booking);
        }
    }

    public enum PaymentStatus
    {
        NaCekanju,
        Uspješno,
        Neuspješno,
        Refundirano
    }
}