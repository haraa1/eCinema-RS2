using AutoMapper;
using eCinema.Model.Entities;
using eCinema.Models;
using eCinema.Models.DTOs.Actors;
using eCinema.Models.SearchObjects;
using eCinema.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Services.Services
{
    public class ActorService : BaseCRUDService<ActorDto, Actor, ActorSearch, ActorInsertDto, ActorUpdateDto>, IActorService
    {
        public ActorService(eCinemaDbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }
        public override IQueryable<Actor> AddFilter(IQueryable<Actor> query, ActorSearch? search = null)
        {
            var filteredQuery = base.AddFilter(query, search);

            if (!string.IsNullOrWhiteSpace(search?.Name))
            {
                filteredQuery = filteredQuery.Where(x => x.FirstName.Contains(search.Name) || x.LastName.Contains(search.Name));
            }

            return filteredQuery;
        }
    }
}
