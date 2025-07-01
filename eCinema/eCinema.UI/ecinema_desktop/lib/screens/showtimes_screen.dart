import 'package:ecinema_desktop/screens/showtime_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ecinema_desktop/models/showtime.dart';
import 'package:ecinema_desktop/models/movie.dart';
import 'package:ecinema_desktop/models/cinema_hall.dart';
import 'package:ecinema_desktop/providers/showtime_provider.dart';
import 'package:ecinema_desktop/providers/movie_provider.dart';
import 'package:ecinema_desktop/providers/cinema_hall_provider.dart';

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
  Map<int, Movie> _moviesMap = {};
  Map<int, CinemaHall> _cinemaHallsMap = {};

  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  int _pageSize = 10;
  int _totalCount = 0;
  DateTime? _selectedDateFilter;

  @override
  void initState() {
    super.initState();

    _loadAuxiliaryDataAndShowtimes();
  }

  Future<void> _loadAuxiliaryDataAndShowtimes() async {
    setState(() => _isLoading = true);
    try {
      if (_moviesMap.isEmpty || _cinemaHallsMap.isEmpty) {
        final movieResult = await _movieProvider.get(
          filter: {'pageSize': 1000},
        );
        final hallResult = await _cinemaHallProvider.get(
          filter: {'pageSize': 1000},
        );
        if (mounted) {
          setState(() {
            _moviesMap = {for (var m in movieResult.result) m.id!: m};
            _cinemaHallsMap = {for (var h in hallResult.result) h.id!: h};
          });
        }
      }
      await _loadShowtimes(showLoading: false);
    } catch (e) {
      if (mounted) {
        print("Error loading auxiliary data: $e");
        setState(() {
          _error = "Greška pri učitavanju pomoćnih podataka: ${e.toString()}";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadShowtimes({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    try {
      Map<String, dynamic> filter = {
        "Page": _currentPage - 1,
        "PageSize": _pageSize,
        "Title": _searchController.text.trim(),
      };
      if (_selectedDateFilter != null) {
        filter["Date"] = DateFormat('yyyy-MM-dd').format(_selectedDateFilter!);
      }

      final result = await _showtimeProvider.get(filter: filter);
      if (mounted) {
        setState(() {
          _showtimes = result.result;
          _totalCount = result.count ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading showtimes: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = "Greška pri učitavanju projekcija: ${e.toString()}";
        });
      }
    }
  }

  int get _totalPages => _totalCount > 0 ? (_totalCount / _pageSize).ceil() : 1;

  void _navigateToForm({Showtime? showtime}) async {
    final bool? shouldRefresh = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => ShowtimeFormScreen(showtime: showtime),
      ),
    );
    if (shouldRefresh == true && mounted) {
      _loadShowtimes();
    }
  }

  Future<void> _deleteShowtime(int showtimeId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Potvrda brisanja"),
            content: const Text(
              "Da li ste sigurni da želite obrisati ovu projekciju? Povezane rezervacije mogu biti pogođene.",
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

    if (confirm == true && mounted) {
      try {
        setState(() => _isLoading = true);
        await _showtimeProvider.delete(showtimeId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Projekcija uspješno obrisana."),
              backgroundColor: Colors.green,
            ),
          );
          if (_showtimes.length == 1 && _currentPage > 1) {
            _currentPage--;
          }
          _loadShowtimes(showLoading: false);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Greška pri brisanju projekcije: ${e.toString()}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _pickDateFilter() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateFilter ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDateFilter) {
      setState(() {
        _selectedDateFilter = picked;
        _currentPage = 1;
      });
      _loadShowtimes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Pretraži po naslovu filma...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 16,
                      ),
                    ),
                    onSubmitted: (_) {
                      _currentPage = 1;
                      _loadShowtimes();
                    },
                  ),
                ),
                const SizedBox(width: 10),

                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    _currentPage = 1;
                    _loadShowtimes();
                  },
                  icon: const Icon(Icons.search),
                  label: const Text("Pretraži"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => _navigateToForm(),
                  icon: const Icon(Icons.add),
                  label: const Text("Dodaj projekciju"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              Expanded(
                child: Center(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              )
            else if (_showtimes.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    "Nema pronađenih projekcija za odabrane kriterije.",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              )
            else
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: constraints.maxWidth,
                                ),
                                child: DataTable(
                                  columnSpacing: 15,
                                  headingRowColor:
                                      MaterialStateColor.resolveWith(
                                        (states) => Theme.of(
                                          context,
                                        ).primaryColorLight.withOpacity(0.3),
                                      ),
                                  columns: const [
                                    DataColumn(
                                      label: Text(
                                        "ID",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        "FILM",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        "DVORANA",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        "POČETAK",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        "KRAJ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        "CIJENA (KM)",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        "AKCIJE",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                  rows: _buildRows(),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (_totalPages > 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.first_page),
                              onPressed:
                                  _currentPage > 1
                                      ? () {
                                        setState(() => _currentPage = 1);
                                        _loadShowtimes();
                                      }
                                      : null,
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed:
                                  _currentPage > 1
                                      ? () {
                                        setState(() => _currentPage--);
                                        _loadShowtimes();
                                      }
                                      : null,
                            ),
                            Text("Stranica $_currentPage od $_totalPages"),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed:
                                  _currentPage < _totalPages
                                      ? () {
                                        setState(() => _currentPage++);
                                        _loadShowtimes();
                                      }
                                      : null,
                            ),
                            IconButton(
                              icon: const Icon(Icons.last_page),
                              onPressed:
                                  _currentPage < _totalPages
                                      ? () {
                                        setState(
                                          () => _currentPage = _totalPages,
                                        );
                                        _loadShowtimes();
                                      }
                                      : null,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<DataRow> _buildRows() {
    final DateFormat dateTimeFormatter = DateFormat('dd.MM.yyyy HH:mm');
    return _showtimes.map((showtime) {
      final movieName =
          showtime.movie?.title ?? _moviesMap[showtime.movieId]?.title ?? "N/A";
      final hallName =
          showtime.cinemaHall?.name ??
          _cinemaHallsMap[showtime.cinemaHallId]?.name ??
          "N/A";

      return DataRow(
        cells: [
          DataCell(Text(showtime.id?.toString() ?? 'N/A')),
          DataCell(
            Tooltip(
              message: movieName,
              child: SizedBox(
                width: 150,
                child: Text(movieName, overflow: TextOverflow.ellipsis),
              ),
            ),
          ),
          DataCell(
            Tooltip(
              message: hallName,
              child: SizedBox(
                width: 120,
                child: Text(hallName, overflow: TextOverflow.ellipsis),
              ),
            ),
          ),
          DataCell(
            Text(
              showtime.startTime != null
                  ? dateTimeFormatter.format(showtime.startTime!)
                  : 'N/A',
            ),
          ),
          DataCell(
            Text(
              showtime.endTime != null
                  ? dateTimeFormatter.format(showtime.endTime!)
                  : 'N/A',
            ),
          ),
          DataCell(Text(showtime.basePrice?.toStringAsFixed(2) ?? "-")),
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                  tooltip: "Uredi projekciju",
                  onPressed: () => _navigateToForm(showtime: showtime),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  tooltip: "Obriši projekciju",
                  onPressed: () => _deleteShowtime(showtime.id!),
                ),
              ],
            ),
          ),
        ],
      );
    }).toList();
  }
}
