import 'package:flutter/material.dart';
import '../models/showtime.dart';

class ShowtimeCard extends StatelessWidget {
  final Showtime showtime;
  const ShowtimeCard({Key? key, required this.showtime}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final movie = showtime.movie;
    final start = TimeOfDay.fromDateTime(showtime.startTime);
    final end = TimeOfDay.fromDateTime(showtime.endTime);
    final hall = showtime.cinemaHall.name;
    final cinema = showtime.cinema;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.grey[200],
              child:
                  movie.title != null
                      ? Center(
                        child: Icon(
                          Icons.movie_filter,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                      )
                      : const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 64,
                          color: Colors.grey,
                        ),
                      ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title ?? 'Bez naslova',
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
    );
  }
}
