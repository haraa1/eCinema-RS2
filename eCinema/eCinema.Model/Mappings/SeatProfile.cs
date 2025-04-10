using AutoMapper;
using eCinema.Model.Entities;
using eCinema.Models.DTOs.Seats;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.Mappings
{
    public class SeatProfile : Profile
    {
        public SeatProfile()
        {
            CreateMap<Seat, SeatDto>();
            CreateMap<SeatInsertDto, Seat>();
            CreateMap<SeatUpdateDto, Seat>();

            CreateMap<Seat, SeatDistributionDto>()
                .ForMember(dest => dest.SeatTypeId, opt => opt.MapFrom(src => src.SeatTypeId))
                .ForMember(dest => dest.SeatTypeName, opt => opt.MapFrom(src => src.SeatType.Name))
                .ForMember(dest => dest.Count, opt => opt.Ignore());

            CreateMap<SeatDistributionUpdateDto, SeatDistributionDto>()
                .ForMember(dest => dest.SeatTypeId, opt => opt.MapFrom(src => src.SeatTypeId))
                .ForMember(dest => dest.SeatTypeName, opt => opt.Ignore())
                .ForMember(dest => dest.Count, opt => opt.MapFrom(src => src.Count));
        }
    }
}
