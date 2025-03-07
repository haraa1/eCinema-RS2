using AutoMapper;
using eCinema.Model.Entities;
using eCinema.Models.DTOs.Actors;
using eCinema.Models.DTOs.Cinemas;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.Mappings
{
    public class ActorProfile : Profile
    {
        public ActorProfile()
        {
            CreateMap<Actor, ActorDto>();
            CreateMap<ActorInsertDto, Actor>();
            CreateMap<ActorUpdateDto, Actor>();
        }
    }
}
