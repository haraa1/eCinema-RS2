using eCinema.Models.DTOs.Discounts;
using eCinema.Models.SearchObjects;
using eCinema.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace eCinema.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class DiscountController
    : BaseCRUDController<DiscountDto, DiscountSearchObject, DiscountInsertDto, DiscountUpdateDto>
    {
        public DiscountController(
            ILogger<BaseController<DiscountDto, DiscountSearchObject>> logger,
            IDiscountService service)
            : base(logger, service)
        {
        }
    }
}
