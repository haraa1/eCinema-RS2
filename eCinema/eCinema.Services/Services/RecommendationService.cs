using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.ML;
using Microsoft.ML.Data;
using eCinema.Models;
using eCinema.Models.DTOs.Showtimes;

namespace eCinema.Services.Recommendations
{
    public interface IRecommendationService
    {
        Task<IReadOnlyList<ShowtimeDto>> RecommendAsync(
            int userId,
            int take = 10,
            CancellationToken ct = default);
    }
    public class RecommendationService : IRecommendationService
    {
        static readonly object _syncRoot = new();
        static MLContext _ml;
        static Dictionary<int, float[]> _movieVectors;

        readonly eCinemaDbContext _db;
        readonly IMapper _mapper;

        public RecommendationService(eCinemaDbContext db, IMapper mapper)
        {
            _db = db;
            _mapper = mapper;
            BuildModelIfNeeded();
        }

        public async Task<IReadOnlyList<ShowtimeDto>> RecommendAsync(
            int userId,
            int take = 10,
            CancellationToken ct = default)
        {
            var watched = await _db.Bookings
                                   .Where(b => b.UserId == userId)
                                   .Select(b => b.Showtime.MovieId)
                                   .Distinct()
                                   .ToListAsync(ct);

            if (watched.Count == 0) return Array.Empty<ShowtimeDto>();

            var profile = AverageVectors(watched.Select(id => _movieVectors[id]));

            var topMovieIds = _movieVectors
                .Where(kv => !watched.Contains(kv.Key))
                .Select(kv => (kv.Key, Score: Cosine(profile, kv.Value)))
                .OrderByDescending(t => t.Score)
                .Take(take)
                .Select(t => t.Key)
                .ToList();

            if (topMovieIds.Count == 0) return Array.Empty<ShowtimeDto>();

            var now = DateTime.UtcNow;

            var bestShowtimes = await _db.Showtime
                .Where(st => topMovieIds.Contains(st.MovieId) && st.StartTime >= now)
                .Include(st => st.Movie)
                    .ThenInclude(m => m.MovieGenres).ThenInclude(mg => mg.Genre)
                .Include(st => st.Movie)
                    .ThenInclude(m => m.MovieActors).ThenInclude(ma => ma.Actor)
                .Include(st => st.CinemaHall).ThenInclude(ch => ch.Cinema)
                .GroupBy(st => st.MovieId)
                .Select(g => g.OrderBy(st => st.StartTime).First())
                .ToListAsync(ct);

            var ordered = topMovieIds
                .Select(id => bestShowtimes.FirstOrDefault(st => st.MovieId == id))
                .Where(st => st != null)
                .ToList();

            return _mapper.Map<List<ShowtimeDto>>(ordered);
        }

        void BuildModelIfNeeded()
        {
            if (_movieVectors != null) return;

            lock (_syncRoot)
            {
                if (_movieVectors != null) return;

                _ml = new MLContext();

                var rows = LoadMovieRows();
                var data = _ml.Data.LoadFromEnumerable(rows);
                var pipeline = _ml.Transforms.Text.FeaturizeText("GenresFeats", nameof(MovieRow.Genres))
                                   .Append(_ml.Transforms.Text.FeaturizeText("ActorsFeats", nameof(MovieRow.Actors)))
                                   .Append(_ml.Transforms.Concatenate("Features", "GenresFeats", "ActorsFeats"))
                                   .Append(_ml.Transforms.NormalizeLpNorm("Features"));

                var model = pipeline.Fit(data);
                var transformed = model.Transform(data);
                var vectorRows = _ml.Data.CreateEnumerable<VectorRow>(transformed, reuseRowObject: false);

                _movieVectors = vectorRows.ToDictionary(v => v.MovieId, v => v.Features);
            }
        }

        List<MovieRow> LoadMovieRows()
            => _db.Movies
                  .Include(m => m.MovieGenres).ThenInclude(mg => mg.Genre)
                  .Include(m => m.MovieActors).ThenInclude(ma => ma.Actor)
                  .AsNoTracking()
                  .Select(m => new MovieRow
                  {
                      MovieId = m.Id,
                      Genres = string.Join('|', m.MovieGenres.Select(g => g.Genre.Name)),
                      Actors = string.Join('|', m.MovieActors.Select(
                                  a => $"{a.Actor.FirstName} {a.Actor.LastName}".Trim()))
                  })
                  .ToList();

        static float[] AverageVectors(IEnumerable<float[]> vectors)
        {
            var list = vectors.ToList();
            if (list.Count == 0) return Array.Empty<float>();

            var sum = new float[list[0].Length];
            foreach (var v in list)
                for (var i = 0; i < v.Length; i++)
                    sum[i] += v[i];

            for (var i = 0; i < sum.Length; i++)
                sum[i] /= list.Count;

            return sum;
        }

        static float Cosine(float[] a, float[] b)
        {
            float dot = 0, magA = 0, magB = 0;
            for (var i = 0; i < a.Length; i++)
            {
                dot += a[i] * b[i];
                magA += a[i] * a[i];
                magB += b[i] * b[i];
            }

            const float eps = 1e-6f;
            return dot / (MathF.Sqrt(magA) * MathF.Sqrt(magB) + eps);
        }

        class MovieRow
        {
            public int MovieId { get; set; }
            public string Genres { get; set; }
            public string Actors { get; set; }
        }

        class VectorRow
        {
            public int MovieId { get; set; }

            [VectorType]
            public float[] Features { get; set; }
        }
    }
}
