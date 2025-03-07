using eCinema.Model.Entities;
using eCinema.Models.DTOs.Actors;
using eCinema.Models.SearchObjects;
using eCinema.Services.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Services.Interfaces
{
    public interface IActorService : ICRUDService<ActorDto, ActorSearch, ActorInsertDto, ActorUpdateDto> 
    {
    }
}
