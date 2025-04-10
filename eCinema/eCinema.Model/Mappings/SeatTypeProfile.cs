using AutoMapper;
using eCinema.Models.DTOs.SeatTypes;
using eCinema.Models.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.Mappings
{
    public class SeatTypeProfile : Profile
    {
        public SeatTypeProfile()
        {
            CreateMap<SeatType, SeatTypeDto>();
            CreateMap<SeatTypeInsert, SeatType>();
            CreateMap<SeatTypeUpdateDto, SeatType>();
        }
    }
}
