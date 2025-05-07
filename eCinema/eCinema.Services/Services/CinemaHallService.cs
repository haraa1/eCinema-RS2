using AutoMapper;
using eCinema.Model.Entities;
using eCinema.Models.SearchObjects;
using eCinema.Models;
using eCinema.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using eCinema.Models.DTOs.CinemaHalls;
using Microsoft.EntityFrameworkCore;
using eCinema.Models.DTOs.Seats;

namespace eCinema.Services.Services
{
    public class CinemaHallService : BaseCRUDService<CinemaHallDto, CinemaHall, BaseSearchObject, CinemaHallInsertDto, CinemaHallUpdateDto>, ICinemaHallService
    {
        public CinemaHallService(eCinemaDbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }

        public override IQueryable<CinemaHall> AddInclude(IQueryable<CinemaHall> query, BaseSearchObject search = null)
        {
            return query.Include(ch => ch.Seats)
                        .ThenInclude(s => s.SeatType);
        }

        public override async Task<CinemaHallDto> GetById(int id)
        {
            var entity = await _context.CinemaHalls
                .Include(ch => ch.Seats)
                .ThenInclude(s => s.SeatType)
                .FirstOrDefaultAsync(ch => ch.Id == id);
            return _mapper.Map<CinemaHallDto>(entity);
        }

        public async Task<List<SeatDistributionDto>> GetSeatDistribution(int hallId)
        {
            var hall = await _context.CinemaHalls.Include(ch => ch.Seats)
                                                 .ThenInclude(s => s.SeatType)
                                                 .FirstOrDefaultAsync(ch => ch.Id == hallId);
            if (hall == null)
                throw new Exception("Cinema hall not found");

            var distribution = hall.Seats
                .GroupBy(s => new { s.SeatTypeId, s.SeatType.Name })
                .Select(g => new SeatDistributionDto
                {
                    SeatTypeId = g.Key.SeatTypeId,
                    SeatTypeName = g.Key.Name,
                    Count = g.Count()
                }).ToList();

            return distribution;
        }

        public async Task UpdateSeatDistribution(int hallId, UpdateSeatDistributionDto dto)
        {
            var hall = await _context.CinemaHalls.Include(ch => ch.Seats)
                                                 .FirstOrDefaultAsync(ch => ch.Id == hallId);
            if (hall == null)
                throw new Exception("Cinema hall not found");

            var newTotal = dto.Distributions.Sum(d => d.Count);
            if (newTotal != dto.TotalSeats)
                throw new Exception("The sum of seat type counts does not match the total seats.");

            foreach (var dist in dto.Distributions)
            {
                var currentCount = hall.Seats.Count(s => s.SeatTypeId == dist.SeatTypeId);
                var difference = dist.Count - currentCount;
                if (difference > 0)
                {
                    for (int i = 0; i < difference; i++)
                    {
                        hall.Seats.Add(new Seat
                        {
                            SeatTypeId = dist.SeatTypeId,
                            CinemaHallId = hallId,
                            isAvailable = true,
                            Row = "Default",
                            Number = hall.Seats.Any() ? hall.Seats.Max(s => s.Number) + 1 : 1
                        });
                    }
                }
                else if (difference < 0)
                {
                    var seatsToRemove = hall.Seats.Where(s => s.SeatTypeId == dist.SeatTypeId)
                                                  .Take(Math.Abs(difference))
                                                  .ToList();
                    foreach (var seat in seatsToRemove)
                    {
                        _context.Seats.Remove(seat);
                    }
                }
            }
            await _context.SaveChangesAsync();
        }

        public async Task AddSeats(int hallId, AddSeatsDto dto)
        {
            var hall = await _context.CinemaHalls.FindAsync(hallId);

            if (hall == null)
                throw new Exception("Cinema hall not found");

            int seatsPerRow = 10;
            for (int i = 0; i < dto.NumberOfSeats; i++)
            {
                int rowIndex = i / seatsPerRow;
                string rowLetter = ((char)('A' + rowIndex)).ToString();

                var newSeat = new Seat
                {
                    CinemaHallId = hallId,
                    SeatTypeId = dto.DefaultSeatTypeId,
                    isAvailable = true,
                    Number = (i % seatsPerRow) + 1,
                    Row = rowLetter
                };

                _context.Seats.Add(newSeat);
            }

            await _context.SaveChangesAsync();
        }


        public async Task RemoveSeats(int hallId, RemoveSeatsDto dto)
        {
            var hall = await _context.CinemaHalls.Include(ch => ch.Seats)
                                                 .FirstOrDefaultAsync(ch => ch.Id == hallId);
            if (hall == null)
                throw new Exception("Cinema hall not found");

            var seatsToRemove = hall.Seats.Where(s => s.SeatTypeId == dto.SeatTypeId)
                                          .Take(dto.NumberOfSeats)
                                          .ToList();

            if (seatsToRemove.Count < dto.NumberOfSeats)
                throw new Exception("Not enough seats available to remove.");

            _context.Seats.RemoveRange(seatsToRemove);
            await _context.SaveChangesAsync();
        }
        
        public async Task BulkUpdateSeats(int hallId, BulkUpdateSeatsDto dto)
        {
            var seats = await _context.Seats.Where(s => dto.SeatIds.Contains(s.Id) && s.CinemaHallId == hallId).ToListAsync();
            if (seats.Count != dto.SeatIds.Count)
                throw new Exception("Some seats were not found in the specified hall.");

            seats.ForEach(s => s.SeatTypeId = dto.NewSeatTypeId);
            await _context.SaveChangesAsync();
        }
    }
}
