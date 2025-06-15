using AutoMapper;
using eCinema.Model.Entities;
using eCinema.Models;
using eCinema.Models.DTOs.BookingConcessions;
using eCinema.Models.Entities;
using eCinema.Models.SearchObjects;
using eCinema.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace eCinema.Services.Services
{
    public class BookingConcessionsService : BaseCRUDService<BookingConcessionDto, BookingConcession, BookingConcessionSearchObject, BookingConcessionInsertDto, BookingConcessionUpdateDto>, IBookingConcessionsService
    {
        public BookingConcessionsService(eCinemaDbContext context, IMapper mapper)
            : base(context, mapper)
        {

        }
        public override IQueryable<BookingConcession> AddInclude(IQueryable<BookingConcession> q, BookingConcessionSearchObject s)
        {

            return q.Include(bc => bc.Concession).Include(bc => bc.Booking);
        }

        public override async Task<PagedResult<BookingConcessionDto>> Get(BookingConcessionSearchObject search)
        {
            var query = _context.BookingConcessions
                .Include(bc => bc.Concession)
                .Include(bc => bc.Booking)
                .AsQueryable();

            if (search.LastNMonths.HasValue)
            {
                var cutoff = DateTime.UtcNow.AddMonths(-search.LastNMonths.Value);
                query = query.Where(bc => bc.Booking.BookingTime >= cutoff);
            }

            var entities = await query.ToListAsync();

            var dtos = entities.Select(bc => new BookingConcessionDto
            {
                BookingId = bc.BookingId,
                ConcessionId = bc.ConcessionId,
                ConcessionName = bc.Concession.Name,
                Quantity = bc.Quantity,
                UnitPrice = bc.Concession.Price,
                TotalPrice = bc.Concession.Price * bc.Quantity,
                BookingTime = bc.Booking.BookingTime
            }).ToList();

            return new PagedResult<BookingConcessionDto>
            {
                Count = dtos.Count,
                Result = dtos
            };
        }
    }
}
