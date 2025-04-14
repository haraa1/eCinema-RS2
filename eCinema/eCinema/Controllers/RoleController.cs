using eCinema.Models.DTOs.Roles;
using eCinema.Models.SearchObjects;
using eCinema.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace eCinema.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class RoleController : BaseCRUDController<RoleDto, BaseSearchObject, RoleInsertDto, RoleUpdateDto>
    {
        public RoleController(
            ILogger<BaseController<RoleDto, BaseSearchObject>> logger,
            IRoleService service)
            : base(logger, service)
        {
        }
    }
}
