using AutoMapper;
using eCinema.Models.DTOs.SeatTypes;
using eCinema.Models.DTOs.Showtimes;
using eCinema.Models.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.Mappings
{
    public class ShowtimeProfile : Profile
    {
        public ShowtimeProfile()
        {
            CreateMap<Showtime, ShowtimeDto>();
            CreateMap<ShowtimeInsertDto, Showtime>();
            CreateMap<ShowtimeUpdateDto, Showtime>();
        }
    }
}
