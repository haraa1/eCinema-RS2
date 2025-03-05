using AutoMapper;
using eCinema.Model.Entities;
using eCinema.Models.DTOs.Movies;
using eCinema.Models.SearchObjects;
using eCinema.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using eCinema.Models.DTOs.Cinemas;

namespace eCinema.Services
{
    public class CinemaService : BaseCRUDService<CinemaDto, Cinema, CinemaSearch, CinemaInsertDto, CinemaUpdateDto>, ICinemaService
    {
        public CinemaService(eCinemaDbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }
        public override IQueryable<Cinema> AddFilter(IQueryable<Cinema> query, CinemaSearch? search = null)
        {
            var filteredQuery = base.AddFilter(query, search);

            if (!string.IsNullOrWhiteSpace(search?.City))
            {
                filteredQuery = filteredQuery.Where(x => x.City.Contains(search.City));
            }

            return filteredQuery;
        }


    }
}
