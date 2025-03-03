using AutoMapper;
using eCinema.Model.Entities;
using eCinema.Models.DTOs.Movies;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.Mappings
{
    public class MovieProfile : Profile
    {
        public MovieProfile()
        {
            CreateMap<Movie, MovieDto>();
            CreateMap<MovieInsertDto, Movie>();
            CreateMap<MovieUpdateDto, Movie>();
        }
    }
}
