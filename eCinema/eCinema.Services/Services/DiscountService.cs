using AutoMapper;
using eCinema.Models.DTOs.Discounts;
using eCinema.Models;
using eCinema.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using eCinema.Models.Entities;
using eCinema.Models.SearchObjects;

namespace eCinema.Services.Services
{
    public class DiscountService
        : BaseCRUDService<DiscountDto, Discount, DiscountSearchObject, DiscountInsertDto, DiscountUpdateDto>,
          IDiscountService
    {
        public DiscountService(eCinemaDbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }

        public override IQueryable<Discount> AddFilter(IQueryable<Discount> query, DiscountSearchObject? search = null)
        {
            var filteredQuery = base.AddFilter(query, search);

            if (!string.IsNullOrWhiteSpace(search?.Name))
            
                filteredQuery = filteredQuery.Where(x => x.Code.Contains(search.Name));

               if (search?.IsActive.HasValue == true)
                filteredQuery = filteredQuery.Where(x => x.IsActive == search.IsActive.Value);

            return filteredQuery;
        }
    }
}
