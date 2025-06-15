using AutoMapper;
using eCinema.Model.Entities;
using eCinema.Models.DTOs.Concessions;
using eCinema.Models.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.Mappings
{
    public class ConcessionProfile : Profile
    {
        public ConcessionProfile()
        {
            CreateMap<Concession, ConcessionDto>();
            CreateMap<ConcessionInsertDto, Concession>();
            CreateMap<ConcessionUpdateDto, Concession>();
        }
    }
}
