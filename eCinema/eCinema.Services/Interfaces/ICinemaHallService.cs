using eCinema.Model.Entities;
using eCinema.Models.DTOs.CinemaHalls;
using eCinema.Models.DTOs.Seats;
using eCinema.Models.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Services.Interfaces
{
    public interface ICinemaHallService : ICRUDService<CinemaHallDto, BaseSearchObject, CinemaHallInsertDto, CinemaHallUpdateDto>
    {
        Task<CinemaHallDto> GetById(int id);
        Task<List<SeatDistributionDto>> GetSeatDistribution(int hallId);
        Task UpdateSeatDistribution(int hallId, UpdateSeatDistributionDto dto);
        Task AddSeats(int hallId, AddSeatsDto dto);
        Task RemoveSeats(int hallId, RemoveSeatsDto dto);
        Task BulkUpdateSeats(int hallId, BulkUpdateSeatsDto dto);
    }
}
