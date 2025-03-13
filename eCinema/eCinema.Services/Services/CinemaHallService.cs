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

namespace eCinema.Services.Services
{
    public class CinemaHallService : BaseCRUDService<CinemaHallDto, CinemaHall, BaseSearchObject, CinemaHallInsertDto, CinemaHallUpdateDto>, ICinemaHallService
    {
        public CinemaHallService(eCinemaDbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }

        public override async Task BeforeInsert(CinemaHall entity, CinemaHallInsertDto insert)
        {
            entity.Capacity = insert.Rows * insert.SeatsPerRow;

            entity.Seats = GenerateSeats(insert.Rows, insert.SeatsPerRow, insert.SeatTypeId);

            await Task.CompletedTask;
        }

        public override async Task<CinemaHallDto> Update(int id, CinemaHallUpdateDto update)
        {
            var entity = await _context.CinemaHalls
                .Include(ch => ch.Seats)
                .FirstOrDefaultAsync(ch => ch.Id == id);

            if (entity == null)
                throw new Exception("Cinema hall not found.");

            entity.Name = update.Name;
            entity.CinemaId = update.CinemaId;

            int currentRows = entity.Seats.Select(s => s.Row).Distinct().Count();
            int currentSeatsPerRow = entity.Seats.GroupBy(s => s.Row).FirstOrDefault()?.Count() ?? 0;

            if (currentRows != update.Rows || currentSeatsPerRow != update.SeatsPerRow)
            {
                _context.Seats.RemoveRange(entity.Seats);
                entity.Seats = GenerateSeats(update.Rows, update.SeatsPerRow, update.SeatTypeId);
                entity.Capacity = update.Rows * update.SeatsPerRow;
            }
            else if (entity.Seats.Any() && entity.Seats.First().SeatTypeId != update.SeatTypeId)
            {
                foreach (var seat in entity.Seats)
                {
                    seat.SeatTypeId = update.SeatTypeId;
                }
            }

            await _context.SaveChangesAsync();
            return _mapper.Map<CinemaHallDto>(entity);
        }

        private List<Seat> GenerateSeats(int rows, int seatsPerRow, int seatTypeId)
        {
            var seats = new List<Seat>();
            for (int i = 0; i < rows; i++)
            {
                char rowLetter = (char)('A' + i);
                for (int j = 1; j <= seatsPerRow; j++)
                {
                    seats.Add(new Seat
                    {
                        Row = rowLetter.ToString(),
                        Number = j,
                        SeatTypeId = seatTypeId
                    });
                }
            }
            return seats;
        }
    }
}
