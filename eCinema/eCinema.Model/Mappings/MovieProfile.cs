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
            CreateMap<Movie, MovieDto>().ForMember(dest => dest.ActorIds, opt => opt.MapFrom(src => src.MovieActors.Select(ma => ma.ActorId)))
                                        .ForMember(dest => dest.GenreIds, opt => opt.MapFrom(src => src.MovieGenres.Select(mg => mg.GenreId)));
            CreateMap<MovieInsertDto, Movie>();
            CreateMap<MovieUpdateDto, Movie>();
        }
    }
}
