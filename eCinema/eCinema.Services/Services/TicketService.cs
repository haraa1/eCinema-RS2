using AutoMapper;
using eCinema.Model.Entities;
using eCinema.Models;
using eCinema.Models.DTOs.Tickets;
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
    public class TicketService : BaseCRUDService<TicketDto, Ticket, TicketSearchObject, TicketInsertDto, TicketUpdateDto>, ITicketService
    {
        public TicketService(eCinemaDbContext context, IMapper mapper) : base(context, mapper)
        {

        }

        public override IQueryable<Ticket> AddInclude(IQueryable<Ticket> q, TicketSearchObject s)
        {
            return q.Include(t => t.Booking);
        }
        public override IQueryable<Ticket> AddFilter(IQueryable<Ticket> q, TicketSearchObject s)
        {
            q = base.AddFilter(q, s);

            if (s.LastNMonths.HasValue)
            {
                var cutoff = DateTime.UtcNow.AddMonths(-s.LastNMonths.Value);
                q = q.Where(t => t.Booking.BookingTime >= cutoff);
            }

            return q;
        }

    }
}
