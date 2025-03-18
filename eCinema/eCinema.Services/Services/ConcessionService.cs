using AutoMapper;
using eCinema.Model.Entities;
using eCinema.Models.DTOs.Cinemas;
using eCinema.Models.SearchObjects;
using eCinema.Models;
using eCinema.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using eCinema.Models.DTOs.Concessions;
using eCinema.Models.Entities;

namespace eCinema.Services.Services
{
    public class ConcessionService : BaseCRUDService<ConcessionDto, Concession, NameSearchObject, ConcessionInsertDto, ConcessionUpdateDto>, IConcessionService
    {
        public ConcessionService(eCinemaDbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }
        public override IQueryable<Concession> AddFilter(IQueryable<Concession> query, NameSearchObject? search = null)
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
