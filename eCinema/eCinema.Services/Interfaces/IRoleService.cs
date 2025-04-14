using eCinema.Models.DTOs.Roles;
using eCinema.Models.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Services.Interfaces
{
    public interface IRoleService : ICRUDService<RoleDto, BaseSearchObject, RoleInsertDto, RoleUpdateDto>
    {

    }
}
