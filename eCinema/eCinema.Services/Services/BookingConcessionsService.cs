using AutoMapper;
using eCinema.Model.Entities;
using eCinema.Models;
using eCinema.Models.DTOs.BookingConcessions;
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
    public class BookingConcessionsService : BaseCRUDService<BookingConcessionDto, BookingConcession, BaseSearchObject, BookingConcessionInsertDto, BookingConcessionUpdateDto>, IBookingConcessionsService
    {
        public BookingConcessionsService(eCinemaDbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }
    }
}
