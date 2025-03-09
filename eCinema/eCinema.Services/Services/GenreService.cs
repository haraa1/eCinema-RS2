using AutoMapper;
using eCinema.Model.Entities;
using eCinema.Models.DTOs.Actors;
using eCinema.Models.SearchObjects;
using eCinema.Models;
using eCinema.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using eCinema.Models.DTOs.Genres;

namespace eCinema.Services.Services
{
    public class GenreService : BaseCRUDService<GenreDto, Genre, GenreSearch, GenreInsertDto, GenreUpdateDto>, IGenreService
    {
        public GenreService(eCinemaDbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }
        public override IQueryable<Genre> AddFilter(IQueryable<Genre> query, GenreSearch? search = null)
        {
            var filteredQuery = base.AddFilter(query, search);

            if (!string.IsNullOrWhiteSpace(search?.Name))
            {
                filteredQuery = filteredQuery.Where(x => x.Name.Contains(search.Name));
            }

            return filteredQuery;
        }
    }
}
