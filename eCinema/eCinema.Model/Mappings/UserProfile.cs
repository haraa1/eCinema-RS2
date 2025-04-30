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
        public UserProfile()
        {
            CreateMap<UserInsertDto, User>()
                .ForMember(dest => dest.UserRoles, opt => opt.Ignore());


            CreateMap<User, UserDto>()
                .ForMember(dest => dest.Roles,
                           opt => opt.MapFrom(s => s.UserRoles.Select(ur => ur.Role.Name)))
                .ForMember(dest => dest.HasPicture,
                           opt => opt.MapFrom(s => s.ProfilePicture != null));

            CreateMap<UserUpdateDto, User>()
             .ForMember(dest => dest.UserRoles, opt => opt.Ignore());

        }
    }
}
