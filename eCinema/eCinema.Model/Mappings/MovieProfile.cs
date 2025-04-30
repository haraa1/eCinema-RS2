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
            CreateMap<Movie, MovieDto>()
                .ForMember(dest => dest.ActorIds,
                           opt => opt.MapFrom(s => s.MovieActors.Select(ma => ma.ActorId)))
                .ForMember(dest => dest.GenreIds,
                           opt => opt.MapFrom(s => s.MovieGenres.Select(mg => mg.GenreId)))
                .ForMember(dest => dest.HasPoster,
                           opt => opt.MapFrom(s => s.PosterImage != null));
            CreateMap<MovieInsertDto, Movie>();
            CreateMap<MovieUpdateDto, Movie>();
        }
    }
}
