import 'package:ecinema_mobile/providers/base_provider.dart';
import 'package:ecinema_mobile/screens/movie_details_screen.dart';
import 'package:flutter/material.dart';
import '../models/showtime.dart';
import 'package:ecinema_mobile/providers/movie_provider.dart';

class ShowtimeCard extends StatelessWidget {
  final Showtime showtime;
  const ShowtimeCard({Key? key, required this.showtime}) : super(key: key);

  String? _fullPosterUrl() {
    final id = showtime.movie.id;
    if (id == null) return null;
    return '${BaseProvider.baseUrl}Movie/$id/poster';
  }

  Widget _buildPoster() {
    final movie = showtime.movie;
    final posterUrl = _fullPosterUrl();
    final headers = BaseProvider.createHeaders();

    if (movie.hasPoster && posterUrl != null) {
      return Image.network(
        posterUrl,
        headers: headers,
        fit: BoxFit.cover,
        loadingBuilder: (ctx, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder:
            (ctx, error, stack) =>
                const Center(child: Icon(Icons.broken_image, size: 48)),
      );
    }

    return Center(
      child: Icon(Icons.movie_filter, size: 64, color: Colors.grey[400]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final start = TimeOfDay.fromDateTime(showtime.startTime);
    final end = TimeOfDay.fromDateTime(showtime.endTime);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => MovieDetailsScreen(
                  showtimeId: showtime.id!,
                  cinemaId: showtime.cinema.id,
                ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(color: Colors.grey[200], child: _buildPoster()),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    showtime.movie.title ?? 'Bez naslova',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'od ${showtime.basePrice.toStringAsFixed(0)} KM',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
