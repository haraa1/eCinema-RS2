using AutoMapper;
using eCinema.Model.Entities;
using eCinema.Models;
using eCinema.Models.DTOs.Bookings;
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
    public class BookingService : BaseCRUDService<BookingDto, Booking, BaseSearchObject, BookingInsertDto, BookingUpdateDto>, IBookingService
    {
        private readonly ITicketService _ticketService;
        private readonly IBookingConcessionsService _bookingConcessionsService;

        public BookingService(
            eCinemaDbContext context,
            IMapper mapper,
            ITicketService ticketService,
            IBookingConcessionsService bookingConcessionsService)
            : base(context, mapper)
        {
            _ticketService = ticketService;
            _bookingConcessionsService = bookingConcessionsService;
        }

        public override async Task<BookingDto> Insert(BookingInsertDto insert)
        {
            using var transaction = await _context.Database.BeginTransactionAsync();

            try
            {
                var bookingEntity = _mapper.Map<Booking>(insert);

                if (insert.Tickets != null && insert.Tickets.Any())
                {
                    bookingEntity.Tickets.Clear();

                    foreach (var ticketInsert in insert.Tickets)
                    {
                        var ticket = new Ticket
                        {
                            SeatId = ticketInsert.SeatId,
                            TicketTypeId = ticketInsert.TicketTypeId,
                            Price = ticketInsert.Price
                        };
                        bookingEntity.Tickets.Add(ticket);
                    }
                }

                if (insert.BookingConcessions != null && insert.BookingConcessions.Any())
                {
                    foreach (var concessionInsert in insert.BookingConcessions)
                    {
                        var bookingConcession = new BookingConcession
                        {
                            ConcessionId = concessionInsert.ConcessionId,
                            Quantity = concessionInsert.Quantity
                        };
                        bookingEntity.BookingConcessions.Add(bookingConcession);
                    }
                }

                _context.Bookings.Add(bookingEntity);

                await _context.SaveChangesAsync();

                var updatedBooking = await GetBookingWithDetails(bookingEntity.Id);

                await transaction.CommitAsync();

                return updatedBooking;
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                throw new Exception($"Error creating booking: {ex.Message}", ex);
            }
        }

        private async Task<BookingDto> GetBookingWithDetails(int id)
        {
            var booking = await _context.Bookings
                .Include(b => b.Tickets)
                    .ThenInclude(t => t.TicketType)
                .Include(b => b.Tickets)
                    .ThenInclude(t => t.Seat)
                .Include(b => b.BookingConcessions)
                    .ThenInclude(bc => bc.Concession)
                .Include(b => b.User)
                .Include(b => b.Showtime)
                .FirstOrDefaultAsync(b => b.Id == id);

            return _mapper.Map<BookingDto>(booking);
        }

        public override IQueryable<Booking> AddInclude(IQueryable<Booking> query, BaseSearchObject? search = null)
        {
            return query
                .Include(b => b.Tickets)
                .Include(b => b.BookingConcessions)
                .Include(b => b.User)
                .Include(b => b.Showtime);
        }
    }
}