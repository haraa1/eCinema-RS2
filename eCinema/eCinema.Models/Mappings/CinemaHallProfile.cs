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

            CreateMap<CinemaHall, CinemaHallDto>()
            .ForMember(dest => dest.CinemaName, opt => opt.MapFrom(src => src.Cinema.Name))
            .ForMember(dest => dest.Seats, opt => opt.MapFrom(src => src.Seats));

            CreateMap<CinemaHallInsertDto, CinemaHall>();
            CreateMap<CinemaHallUpdateDto, CinemaHall>();
        }

    }
}
