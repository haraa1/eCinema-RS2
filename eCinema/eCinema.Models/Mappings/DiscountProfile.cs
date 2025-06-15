using AutoMapper;
using eCinema.Models.DTOs.Discounts;
using eCinema.Models.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.Mappings
{
    public class DiscountProfile : Profile
    {
        public DiscountProfile()
        {
            CreateMap<Discount, DiscountDto>();

            CreateMap<DiscountInsertDto, Discount>();

            CreateMap<DiscountUpdateDto, Discount>();
        }
    }
}
