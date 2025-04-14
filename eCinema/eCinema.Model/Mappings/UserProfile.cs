using AutoMapper;
using eCinema.Models.DTOs.Roles;
using eCinema.Models.DTOs.Users;
using eCinema.Models.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.Mappings
{
    public class UserProfile : Profile
    {
        public UserProfile() {
            CreateMap<User, UserDto>().ForMember(dest => dest.Roles, opt => opt.MapFrom(src => src.UserRoles.Select(ur => ur.Role.Name).ToList()));

            CreateMap<Role, RoleDto>();
            CreateMap<UserInsertDto, User>();
            CreateMap<UserUpdateDto, User>()
                 .ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));

        }
    }
}
