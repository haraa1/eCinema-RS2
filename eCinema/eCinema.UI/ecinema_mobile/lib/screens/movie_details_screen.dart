import 'package:flutter/material.dart';
import '../models/showtime.dart';
import '../models/actor.dart';
import '../models/genre.dart';
import '../providers/showtime_provider.dart';
import '../providers/actor_provider.dart';
import '../providers/genre_provider.dart';

class MovieDetailsScreen extends StatefulWidget {
  final int showtimeId;
  final int? cinemaId;

  const MovieDetailsScreen({Key? key, required this.showtimeId, this.cinemaId})
    : super(key: key);

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  final _showtimeProvider = ShowtimeProvider();
  final _actorProvider = ActorProvider();
  final _genreProvider = GenreProvider();

  Showtime? _showtime;
  List<Showtime> _relatedShowtimes = [];
  List<Actor> _actors = [];
  List<Genre> _genres = [];
  bool _loading = true;

  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadShowtimeDetails();
  }

  Future<void> _loadShowtimeDetails() async {
    final showtime = await _showtimeProvider.getById(widget.showtimeId);
    if (showtime == null) return;

    final actorFutures = (showtime.movie.actorIds ?? []).map(
      (id) async => await _actorProvider.getById(id),
    );
    final genreFutures = (showtime.movie.genreIds ?? []).map(
      (id) async => await _genreProvider.getById(id),
    );

    final actors = await Future.wait(actorFutures);
    final genres = await Future.wait(genreFutures);

    final allRelated = await _showtimeProvider.get({
      'movieId': showtime.movie.id,
    });
    final filteredRelated =
        allRelated
            .where(
              (s) =>
                  s.movie.id == showtime.movie.id &&
                  (widget.cinemaId == null || s.cinema.id == widget.cinemaId),
            )
            .toList();

    setState(() {
      _showtime = showtime;
      _actors = actors.whereType<Actor>().toList();
      _genres = genres.whereType<Genre>().toList();
      _relatedShowtimes = filteredRelated;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final movie = _showtime!.movie;
    final posterUrl =
        (movie.hasPoster ?? false)
            ? 'https://10.0.2.2:7012/Movie/${movie.id}/poster'
            : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(movie.title ?? ''),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child:
                posterUrl != null
                    ? Image.network(posterUrl, fit: BoxFit.cover)
                    : const Center(child: Icon(Icons.image, size: 80)),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    children: [
                      ..._genres.map((g) => _buildTag(g.name ?? '')),
                      _buildTag('${movie.durationMinutes} min'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(movie.description ?? 'Nema opisa.'),
                  const SizedBox(height: 12),
                  _buildMetadata('Jezik:', movie.language ?? ''),
                  _buildMetadata('Kino:', _showtime!.cinema.name),
                  _buildMetadata(
                    'Glumci:',
                    _actors
                        .map((a) => '${a.firstName ?? ''} ${a.lastName ?? ''}')
                        .join(', '),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Termini projekcija',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _buildDateSelector(),
                  const SizedBox(height: 12),
                  ..._buildGroupedShowtimes(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    final now = DateTime.now();
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = now.add(Duration(days: index));
          final isSelected =
              _selectedDate.day == date.day &&
              _selectedDate.month == date.month &&
              _selectedDate.year == date.year;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text('${date.day}.${date.month}.'),
              selected: isSelected,
              onSelected: (_) {
                setState(() => _selectedDate = date);
              },
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildGroupedShowtimes() {
    final filtered = _relatedShowtimes.where(
      (s) =>
          s.startTime.year == _selectedDate.year &&
          s.startTime.month == _selectedDate.month &&
          s.startTime.day == _selectedDate.day,
    );

    final grouped = <String, List<Showtime>>{};
    for (final s in filtered) {
      final key = s.cinemaHall.name;
      grouped.putIfAbsent(key, () => []).add(s);
    }

    return grouped.entries.map((entry) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          ...entry.value.map((s) {
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(
                  TimeOfDay.fromDateTime(s.startTime).format(context),
                ),
                trailing: Text(
                  '${s.basePrice.toStringAsFixed(0)} KM',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {},
              ),
            );
          }),
          const SizedBox(height: 16),
        ],
      );
    }).toList();
  }
}

Widget _buildTag(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.grey[300],
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(text, style: const TextStyle(fontSize: 12)),
  );
}

Widget _buildMetadata(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black),
        children: [
          TextSpan(
            text: '$label ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: value),
        ],
      ),
    ),
  );
}
