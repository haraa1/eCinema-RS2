using AutoMapper;
using eCinema.Model.Entities;
using eCinema.Models;
using eCinema.Models.DTOs.Tickets;
using eCinema.Models.Entities;
using eCinema.Models.SearchObjects;
using eCinema.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace eCinema.Services.Services
{
    public class TicketService : BaseCRUDService<TicketDto, Ticket, BaseSearchObject, TicketInsertDto, TicketUpdateDto>, ITicketService
    {
        public TicketService(eCinemaDbContext context, IMapper mapper) : base(context, mapper)
        {
        }
    }
}
