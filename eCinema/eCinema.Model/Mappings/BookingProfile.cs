using AutoMapper;
using eCinema.Models.DTOs.BookingConcessions;
using eCinema.Models.DTOs.Bookings;
using eCinema.Models.DTOs.Tickets;
using eCinema.Models.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.Mappings
{
    public class BookingProfile : Profile
    {
        public BookingProfile()
        {
            CreateMap<Booking, BookingDto>()
                .ForMember(dest => dest.Tickets, opt => opt.MapFrom(src => src.Tickets))
                .ForMember(dest => dest.BookingConcessions, opt => opt.MapFrom(src => src.BookingConcessions));

            CreateMap<BookingInsertDto, Booking>()
                .ForMember(dest => dest.Id, opt => opt.Ignore())
                .ForMember(dest => dest.User, opt => opt.Ignore())
                .ForMember(dest => dest.Showtime, opt => opt.Ignore())
                .ForMember(dest => dest.Tickets, opt => opt.Ignore())
                .ForMember(dest => dest.BookingConcessions, opt => opt.Ignore());

            CreateMap<BookingConcession, BookingConcessionDto>();

            CreateMap<BookingConcessionInsertDto, BookingConcession>()
                .ForMember(dest => dest.Booking, opt => opt.Ignore())
                .ForMember(dest => dest.Concession, opt => opt.Ignore())
                .ForMember(dest => dest.BookingId, opt => opt.Ignore());

            CreateMap<Ticket, TicketDto>();
            CreateMap<TicketInsertDto, Ticket>()
                .ForMember(dest => dest.Id, opt => opt.Ignore())
                .ForMember(dest => dest.Price, opt => opt.Ignore())
                .ForMember(dest => dest.Booking, opt => opt.Ignore())
                .ForMember(dest => dest.Seat, opt => opt.Ignore())
                .ForMember(dest => dest.TicketType, opt => opt.Ignore());
            CreateMap<TicketDto, Ticket>()
                .ForMember(dest => dest.Booking, opt => opt.Ignore())
                .ForMember(dest => dest.Seat, opt => opt.Ignore())
                .ForMember(dest => dest.TicketType, opt => opt.Ignore());
        }
    }
}
