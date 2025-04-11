import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ecinema_desktop/models/showtime.dart';
import 'package:ecinema_desktop/models/movie.dart';
import 'package:ecinema_desktop/models/cinema_hall.dart';
import 'package:ecinema_desktop/providers/showtime_provider.dart';
import 'package:ecinema_desktop/providers/movie_provider.dart';
import 'package:ecinema_desktop/providers/cinema_hall_provider.dart';
import 'package:ecinema_desktop/screens/showtime_form_screen.dart';

class ShowtimeListScreen extends StatefulWidget {
  const ShowtimeListScreen({super.key});

  @override
  State<ShowtimeListScreen> createState() => _ShowtimeListScreenState();
}

class _ShowtimeListScreenState extends State<ShowtimeListScreen> {
  final _searchController = TextEditingController();
  final _showtimeProvider = ShowtimeProvider();
  final _movieProvider = MovieProvider();
  final _cinemaHallProvider = CinemaHallProvider();

  List<Showtime> _showtimes = [];
  Map<int, Movie> _movies = {};
  Map<int, CinemaHall> _cinemaHalls = {};

  bool _isLoading = true;
  int _currentPage = 1;
  int _pageSize = 10;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _loadShowtimes();
  }

  Future<void> _loadShowtimes() async {
    setState(() => _isLoading = true);
    try {
      final result = await _showtimeProvider.get(
        filter: {"Page": _currentPage - 1, "PageSize": _pageSize},
      );

      final movieResult = await _movieProvider.get();
      final hallResult = await _cinemaHallProvider.get();

      setState(() {
        _showtimes = result.result;
        _totalCount = result.count ?? 0;
        _movies = {for (var m in movieResult.result) m.id!: m};
        _cinemaHalls = {for (var h in hallResult.result) h.id!: h};
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading showtimes: $e");
    }
  }

  int get _totalPages => (_totalCount / _pageSize).ceil();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ShowtimeFormScreen(),
                  ),
                );
                _loadShowtimes();
              },
              icon: const Icon(Icons.add),
              label: const Text("Dodaj projekciju"),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const CircularProgressIndicator()
        else
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: constraints.maxWidth,
                            ),
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text("FILM")),
                                DataColumn(label: Text("SALA")),
                                DataColumn(label: Text("POČETAK")),
                                DataColumn(label: Text("KRAJ")),
                                DataColumn(label: Text("CIJENA")),
                                DataColumn(label: Text("AKCIJE")),
                              ],
                              rows: _buildRows(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed:
                          _currentPage > 1
                              ? () {
                                setState(() => _currentPage--);
                                _loadShowtimes();
                              }
                              : null,
                    ),
                    Text("$_currentPage / $_totalPages"),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed:
                          _currentPage < _totalPages
                              ? () {
                                setState(() => _currentPage++);
                                _loadShowtimes();
                              }
                              : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  List<DataRow> _buildRows() {
    return _showtimes.map((s) {
      final movie = s.movie ?? _movies[s.movieId];
      final hall = s.cinemaHall ?? _cinemaHalls[s.cinemaHallId];
      final start =
          s.startTime != null
              ? DateFormat('yyyy-MM-dd HH:mm').format(s.startTime!)
              : '';
      final end =
          s.endTime != null
              ? DateFormat('yyyy-MM-dd HH:mm').format(s.endTime!)
              : '';

      return DataRow(
        cells: [
          DataCell(Text(movie?.title ?? "")),
          DataCell(Text(hall?.name ?? "")),
          DataCell(Text(start)),
          DataCell(Text(end)),
          DataCell(Text("${s.basePrice?.toStringAsFixed(2) ?? ""} KM")),
          DataCell(
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ShowtimeFormScreen(showtime: s),
                      ),
                    );
                    _loadShowtimes();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder:
                          (ctx) => AlertDialog(
                            title: const Text("Potvrda brisanja"),
                            content: const Text(
                              "Da li ste sigurni da želite obrisati ovu projekciju?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text("Otkaži"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text(
                                  "Obriši",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                    );
                    if (confirm == true) {
                      try {
                        await _showtimeProvider.delete(s.id!);
                        _loadShowtimes();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Projekcija obrisana.")),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Greška pri brisanju: $e"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      );
    }).toList();
  }
}
