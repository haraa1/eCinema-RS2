﻿using AutoMapper;
using AutoMapper.QueryableExtensions;
using eCinema.Model.Entities;
using eCinema.Models;
using eCinema.Models.DTOs.Bookings;
using eCinema.Models.Entities;
using eCinema.Models.Messages;
using eCinema.Models.SearchObjects;
using eCinema.Services.Interfaces;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace eCinema.Services.Services
{
    public class BookingService : BaseCRUDService<BookingDto, Booking, BookingSearchObject, BookingInsertDto, BookingUpdateDto>, IBookingService
    {
        private readonly IHttpContextAccessor _http;

        public BookingService(
            eCinemaDbContext context,
            IMapper mapper,
            IHttpContextAccessor http)
            : base(context, mapper)
        {
            _http = http;
        }

        public override IQueryable<Booking> AddFilter(IQueryable<Booking> query, BookingSearchObject? s)
        {
            if (s == null) return query;

            if (s.UserId.HasValue)
                query = query.Where(b => b.UserId == s.UserId.Value);

            if (s.ShowtimeId.HasValue)
                query = query.Where(b => b.ShowtimeId == s.ShowtimeId.Value);

            if (!string.IsNullOrWhiteSpace(s.DiscountCode))
                query = query.Where(b => b.DiscountCode == s.DiscountCode);

            if (s.BookingTimeFrom.HasValue)
                query = query.Where(b => b.BookingTime >= s.BookingTimeFrom.Value);

            if (s.BookingTimeTo.HasValue)
                query = query.Where(b => b.BookingTime <= s.BookingTimeTo.Value);

            return query;
        }

        public override async Task<BookingDto> Insert(BookingInsertDto insert)
        {
            var claimValue = _http.HttpContext?.User?
                .FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)
                ?.Value;

            if (!int.TryParse(claimValue, out var userId))
                throw new UnauthorizedAccessException("User-id claim missing.");

            try
            {
                var bookingEntity = _mapper.Map<Booking>(insert);
                bookingEntity.UserId = userId;
                bookingEntity.BookingTime = DateTime.UtcNow;

                if (!string.IsNullOrWhiteSpace(insert.DiscountCode))
                {
                    var discount = await _context.Discounts
                        .FirstOrDefaultAsync(d => d.Code == insert.DiscountCode && d.IsActive && d.ValidTo >= DateTime.UtcNow);

                    if (discount == null)
                    {
                        throw new InvalidDiscountCodeException("Invalid or expired discount code provided.");
                    }
                    else
                    {
                        bookingEntity.AppliedDiscountId = discount.Id;
                        bookingEntity.DiscountCode = discount.Code;
                    }
                }
                else
                {
                    bookingEntity.DiscountCode = null;
                    bookingEntity.AppliedDiscountId = null;
                }

                if (insert.Tickets != null && insert.Tickets.Any())
                {
                    bookingEntity.Tickets.Clear();

                    foreach (var t in insert.Tickets)
                    {
                        bookingEntity.Tickets.Add(new Ticket
                        {
                            SeatId = t.SeatId,
                            TicketTypeId = t.TicketTypeId,
                            Price = t.Price
                        });
                    }
                }

                if (insert.BookingConcessions != null && insert.BookingConcessions.Any())
                {
                    bookingEntity.BookingConcessions.Clear();

                    foreach (var c in insert.BookingConcessions)
                    {
                        bookingEntity.BookingConcessions.Add(new BookingConcession
                        {
                            ConcessionId = c.ConcessionId,
                            Quantity = c.Quantity
                        });
                    }
                }

                _context.Bookings.Add(bookingEntity);
                await _context.SaveChangesAsync();

                var result = await GetBookingWithDetails(bookingEntity.Id);
                return result;
            }
            catch (InvalidDiscountCodeException)
            {
                throw;
            }
            catch (UnauthorizedAccessException)
            {
                throw;
            }
            catch (Exception ex)
            {
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
                .Include(b => b.AppliedDiscount)
                .FirstOrDefaultAsync(b => b.Id == id);

            return _mapper.Map<BookingDto>(booking);
        }

        public override IQueryable<Booking> AddInclude(IQueryable<Booking> query, BookingSearchObject? search = null)
        {
            return query
                .Include(b => b.Tickets)
                .Include(b => b.BookingConcessions)
                .Include(b => b.User)
                .Include(b => b.Showtime)
                .Include(b => b.AppliedDiscount);
        }

        public async Task<IEnumerable<BookingDto>> GetCurrentUserBookings()
        {
            var claim = _http.HttpContext?.User?
                        .FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier);

            if (claim == null)
                throw new UnauthorizedAccessException("Cannot find user ID in claims.");

            var userId = int.Parse(claim.Value);

            var query = _context.Bookings
                .Where(b => b.UserId == userId)
                .Include(b => b.Tickets)
                    .ThenInclude(t => t.TicketType)
                .Include(b => b.Tickets)
                    .ThenInclude(t => t.Seat)
                .Include(b => b.BookingConcessions)
                    .ThenInclude(bc => bc.Concession)
                .Include(b => b.Showtime)
                .Include(b => b.AppliedDiscount);

            var entities = await query.ToListAsync();

            return _mapper.Map<IEnumerable<BookingDto>>(entities);
        }
    }
}