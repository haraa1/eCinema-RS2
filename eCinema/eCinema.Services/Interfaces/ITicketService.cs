// ITicketService.cs
using eCinema.Models.DTOs.Movies;
using eCinema.Models.DTOs.Tickets;
using eCinema.Models.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Services.Interfaces
{
    public interface ITicketService
        : ICRUDService<TicketDto, TicketSearchObject, TicketInsertDto, TicketUpdateDto>
    {
    }
}
