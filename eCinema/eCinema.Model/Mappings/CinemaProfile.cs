using AutoMapper;
using eCinema.Model.Entities;
using eCinema.Models.DTOs.Cinemas;
using eCinema.Models.DTOs.Movies;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.Mappings
{
    public class CinemaProfile : Profile
    {
        public CinemaProfile()
        {
            CreateMap<Cinema, CinemaDto>();
            CreateMap<CinemaInsertDto, Cinema>();
            CreateMap<CinemaUpdateDto, Cinema>();
        }
    }
}
