using eCinema.Models.DTOs.Seats;
using eCinema.Models.DTOs.SeatTypes;
using eCinema.Models.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Services.Interfaces
{
    public interface ISeatTypeService : ICRUDService<SeatTypeDto, BaseSearchObject, SeatTypeInsert, SeatTypeUpdateDto>
    {

    }
}
