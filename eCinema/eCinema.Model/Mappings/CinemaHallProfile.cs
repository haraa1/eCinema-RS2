using AutoMapper;
using eCinema.Model.Entities;
using eCinema.Models.DTOs.CinemaHalls;
using eCinema.Models.DTOs.Seats;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.Mappings
{
    public class CinemaHallProfile : Profile
    {
        public CinemaHallProfile()
        {
            CreateMap<CinemaHall, CinemaHallDto>().ForMember(dest => dest.Seats, opt => opt.MapFrom(src => src.Seats));

            CreateMap<Seat, SeatDto>();

            CreateMap<CinemaHallInsertDto, CinemaHall>().ForMember(dest => dest.Capacity, opt => opt.Ignore())
                                                        .ForMember(dest => dest.Seats, opt => opt.Ignore());

            CreateMap<CinemaHallUpdateDto, CinemaHall>().ForMember(dest => dest.Capacity, opt => opt.Ignore())
                                                        .ForMember(dest => dest.Seats, opt => opt.Ignore());
        }
    }

}
