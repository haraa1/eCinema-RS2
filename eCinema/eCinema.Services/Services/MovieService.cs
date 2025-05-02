using AutoMapper;
using eCinema.Model.Entities;
using eCinema.Models;
using eCinema.Models.DTOs.Movies;
using eCinema.Models.SearchObjects;
using eCinema.Services.Interfaces;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Services.Services
{
    public class MovieService : BaseCRUDService<MovieDto, Movie, MovieSearch, MovieInsertDto, MovieUpdateDto>, IMovieService
    {
        public MovieService(eCinemaDbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }
        public override IQueryable<Movie> AddFilter(IQueryable<Movie> query, MovieSearch? search = null)
        {
            var filteredQuery = base.AddFilter(query, search);

            if (!string.IsNullOrWhiteSpace(search?.Title))
            {
                filteredQuery = filteredQuery.Where(x => x.Title.Contains(search.Title));
            }

            if (search.Status.HasValue)
            {
                filteredQuery = filteredQuery.Where(x => x.Status == search.Status.Value);
            }

            return filteredQuery;
        }

        public override async Task BeforeInsert(Movie entity, MovieInsertDto insert)
        {
            if (insert.ActorIds != null && insert.ActorIds.Any())
            {
                foreach (var actorId in insert.ActorIds)
                {
                    entity.MovieActors.Add(new MovieActor { ActorId = actorId });
                }
            }
            
            if(insert.GenreIds != null && insert.GenreIds.Any())
            {
                foreach(var genreId in insert.GenreIds)
                {
                    entity.MovieGenres.Add(new MovieGenre {  GenreId = genreId });
                }
            }
        }
        public override IQueryable<Movie> AddInclude(IQueryable<Movie> query, MovieSearch? search = null)
        {
            return query.Include(m => m.MovieActors)
                        .Include(m => m.MovieGenres);
        }

        public override async Task<MovieDto> GetById(int id)
        {
            var entity = await _context.Movies
                .Include(m => m.MovieActors)
                .Include(m => m.MovieGenres)
                .FirstOrDefaultAsync(m => m.Id == id)
                ?? throw new KeyNotFoundException("Movie not found");

            return _mapper.Map<MovieDto>(entity);
        }

        public async Task SetPosterAsync(int id, IFormFile file)
        {
            if (file == null || file.Length == 0)
                throw new ArgumentException("Poster file is empty", nameof(file));

            var movie = await _context.Movies.FindAsync(id)
                        ?? throw new KeyNotFoundException("Movie not found");

            await using var ms = new MemoryStream();
            await file.CopyToAsync(ms);
            movie.PosterImage = ms.ToArray();

            await _context.SaveChangesAsync();
        }

        public async Task<(byte[] Data, string ContentType)?> GetPosterAsync(int id)
        {
            var data = await _context.Movies
                       .Where(m => m.Id == id)
                       .Select(m => m.PosterImage)
                       .SingleOrDefaultAsync();

            return data == null ? null : (data, "image/jpeg");
        }
    }
}
