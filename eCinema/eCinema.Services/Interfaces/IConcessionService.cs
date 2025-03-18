using eCinema.Models.DTOs.Concessions;
using eCinema.Models.Entities;
using eCinema.Models.SearchObjects;
using eCinema.Services.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Services.Interfaces
{
    public interface IConcessionService :  ICRUDService<ConcessionDto, NameSearchObject, ConcessionInsertDto, ConcessionUpdateDto>
    {

    }
}
