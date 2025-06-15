using AutoMapper;
using eCinema.Models.DTOs.BookingConcessions;
using eCinema.Model.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.Threading.Tasks;
using eCinema.Models.Entities;

namespace eCinema.Models.Mappings
{
    public class BookingConcessionsProfile : Profile
    {
        public BookingConcessionsProfile()
        {
            CreateMap<BookingConcession, BookingConcessionDto>()
        .ForMember(d => d.UnitPrice, o => o.MapFrom(s =>
            s.Concession != null ? s.Concession.Price : 0))
        .ForMember(d => d.TotalPrice, o => o.MapFrom(s =>
            s.Concession != null ? s.Concession.Price * s.Quantity : 0))
        .ForMember(d => d.BookingTime, o => o.MapFrom(s =>
            s.Booking != null ? s.Booking.BookingTime : DateTime.MinValue));


        }
    }
}
