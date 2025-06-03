using AutoMapper;
using eCinema.Model.Entities;
using eCinema.Models.DTOs.Seats;
using eCinema.Models.SearchObjects;
using eCinema.Models;
using eCinema.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using eCinema.Models.DTOs.SeatTypes;
using eCinema.Models.Entities;

namespace eCinema.Services.Services
{
    public class SeatTypeService : BaseCRUDService<SeatTypeDto, SeatType, NameSearchObject, SeatTypeInsert, SeatTypeUpdateDto>, ISeatTypeService
    {
        public SeatTypeService(eCinemaDbContext context, IMapper mapper) : base(context, mapper)
        {
        }
        public override IQueryable<SeatType> AddFilter(IQueryable<SeatType> query, NameSearchObject? search = null)
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
