using AutoMapper;
using eCinema.Models.DTOs.Roles;
using eCinema.Models.DTOs.TicketTypes;
using eCinema.Models.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.Mappings
{
    public class TicketTypeProfile : Profile
    {
        public TicketTypeProfile()
        {
            CreateMap<TicketType, TicketTypeDto>();
            CreateMap<TicketTypeInsertDto, TicketType>();
            CreateMap<TicketTypeUpdateDto, TicketType>();
        }
    }
}
