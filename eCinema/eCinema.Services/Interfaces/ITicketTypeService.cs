// ITicketTypeService.cs
using eCinema.Models.DTOs.Movies;
using eCinema.Models.DTOs.TicketTypes;
using eCinema.Models.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Services.Interfaces
{
    public interface ITicketTypeService
        : ICRUDService<TicketTypeDto, NameSearchObject, TicketTypeInsertDto, TicketTypeUpdateDto>
    {
    }
}
