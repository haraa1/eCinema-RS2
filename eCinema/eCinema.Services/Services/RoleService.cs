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
using eCinema.Models.DTOs.Roles;
using eCinema.Models.Entities;

namespace eCinema.Services.Services
{
    public class RoleService : BaseCRUDService<RoleDto, Role, BaseSearchObject, RoleInsertDto, RoleUpdateDto>, IRoleService
    {
        public RoleService(eCinemaDbContext context, IMapper mapper) : base(context, mapper)
        {
        }


    }
}
