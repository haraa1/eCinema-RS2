using AutoMapper;
using eCinema.Model.Entities;
using eCinema.Models;
using eCinema.Models.DTOs.Seats;
using eCinema.Models.SearchObjects;
using eCinema.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace eCinema.Services.Services
{
    public class SeatService : BaseCRUDService<SeatDto, Seat, BaseSearchObject, SeatInsertDto, SeatUpdateDto>, ISeatService
    {
        public SeatService(eCinemaDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        
    }
}
