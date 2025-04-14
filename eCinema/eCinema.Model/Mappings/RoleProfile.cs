using AutoMapper;
using eCinema.Model.Entities;
using eCinema.Models.DTOs.Genres;
using eCinema.Models.DTOs.Movies;
using eCinema.Models.DTOs.Roles;
using eCinema.Models.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.Mappings
{
    public class RoleProfile : Profile
    {
        public RoleProfile()
        {
            CreateMap<Role, RoleDto>();
            CreateMap<RoleInsertDto, Role>();
            CreateMap<RoleUpdateDto, Role>();
        }
    }
}
