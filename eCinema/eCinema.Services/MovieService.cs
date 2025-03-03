using AutoMapper;
using eCinema.Model.Entities;
using eCinema.Models;
using eCinema.Models.DTOs.Movies;
using eCinema.Models.SearchObjects;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Services
{
    public class MovieService : BaseCRUDService<MovieDto, Movie, MovieSearch, MovieInsertDto, MovieUpdateDto>, IMovieService
    {
        public MovieService(eCinemaDbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }
        public override IQueryable<Movie> AddFilter(IQueryable<Movie> query, MovieSearch? search = null)
        {
            var filteredQuery = base.AddFilter(query, search);

            if (!string.IsNullOrWhiteSpace(search?.Title))
            {
                filteredQuery = filteredQuery.Where(x => x.Title.Contains(search.Title));
            }

            return filteredQuery;
        }

        
    }
}
