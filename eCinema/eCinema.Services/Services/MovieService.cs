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

        public override async Task<MovieDto> Update(int id, MovieUpdateDto update)
        {
            var movie = await _context.Movies
                .Include(m => m.MovieActors)
                .Include(m => m.MovieGenres)
                .FirstOrDefaultAsync(m => m.Id == id);

            if (movie == null)
                throw new KeyNotFoundException($"Movie with ID {id} not found.");

            movie.Title = update.Title;
            movie.Description = update.Description;
            movie.DurationMinutes = update.DurationMinutes;
            movie.Language = update.Language;
            movie.ReleaseDate = update.ReleaseDate;
            movie.Status = update.Status;
            movie.PgRating = update.PgRating;

            if (update.ActorIds != null)
            {
                var toRemove = movie.MovieActors
                    .Where(ma => !update.ActorIds.Contains(ma.ActorId))
                    .ToList();
                foreach (var ma in toRemove)
                    _context.MovieActors.Remove(ma);

                var existingIds = movie.MovieActors.Select(ma => ma.ActorId).ToList();
                var toAdd = update.ActorIds.Except(existingIds);
                foreach (var actorId in toAdd)
                    movie.MovieActors.Add(new MovieActor { MovieId = id, ActorId = actorId });
            }

            if (update.GenreIds != null)
            {
                var toRemove = movie.MovieGenres
                    .Where(mg => !update.GenreIds.Contains(mg.GenreId))
                    .ToList();
                foreach (var mg in toRemove)
                    _context.MovieGenres.Remove(mg);

                var existingIds = movie.MovieGenres.Select(mg => mg.GenreId).ToList();
                var toAdd = update.GenreIds.Except(existingIds);
                foreach (var genreId in toAdd)
                    movie.MovieGenres.Add(new MovieGenre { MovieId = id, GenreId = genreId });
            }

            await _context.SaveChangesAsync();

            return _mapper.Map<MovieDto>(movie);
        }
    }
}
