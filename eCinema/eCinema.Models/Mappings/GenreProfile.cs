using AutoMapper;
using eCinema.Model.Entities;
using eCinema.Models.DTOs.Actors;
using eCinema.Models.DTOs.Genres;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.Mappings
{
    public class GenreProfile : Profile
    {
        public GenreProfile()
        {
            CreateMap<Genre, GenreDto>();
            CreateMap<GenreInsertDto, Genre>();
            CreateMap<GenreUpdateDto, Genre>();
        }
    }
}
