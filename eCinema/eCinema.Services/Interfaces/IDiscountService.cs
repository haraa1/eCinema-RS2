using eCinema.Models.DTOs.Discounts;
using eCinema.Models.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Services.Interfaces
{
    public interface IDiscountService : ICRUDService<DiscountDto, DiscountSearchObject, DiscountInsertDto, DiscountUpdateDto>
    {
    }
}
