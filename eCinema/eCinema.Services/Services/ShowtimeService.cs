using AutoMapper;
using eCinema.Models.DTOs.SeatTypes;
using eCinema.Models.Entities;
using eCinema.Models.SearchObjects;
using eCinema.Models;
using eCinema.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using eCinema.Models.DTOs.Showtimes;
using Microsoft.EntityFrameworkCore;

namespace eCinema.Services.Services
{
    public class ShowtimeService : BaseCRUDService<ShowtimeDto, Showtime, BaseSearchObject, ShowtimeInsertDto, ShowtimeUpdateDto>, IShowtimeService
    {
        public ShowtimeService(eCinemaDbContext context, IMapper mapper) : base(context, mapper)
        {
        }
        public override IQueryable<Showtime> AddInclude(IQueryable<Showtime> query, BaseSearchObject search = null)
        {
            return query.Include(s => s.Movie)
                        .Include(s => s.CinemaHall).ThenInclude(s => s.Cinema);
        }

        public override async Task<ShowtimeDto> Insert(ShowtimeInsertDto dto)
        {
            var inserted = await base.Insert(dto);

            var loaded = await _context.Showtime
                             .Include(s => s.Movie)
                             .Include(s => s.CinemaHall)
                                 .ThenInclude(ch => ch.Cinema)
                             .AsNoTracking()
                             .FirstAsync(s => s.Id == inserted.Id);

            return _mapper.Map<ShowtimeDto>(loaded);
        }

    }
}
