using AutoMapper;
using eCinema.Models.DTOs.Tickets;
using eCinema.Models.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.Mappings
{
    public class TicketProfile : Profile
    {
        public TicketProfile() {

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

            CreateMap<Ticket, TicketDto>()
            .ForMember(d => d.BookingTime,
             o => o.MapFrom(s => s.Booking.BookingTime));

        }
    }
}
