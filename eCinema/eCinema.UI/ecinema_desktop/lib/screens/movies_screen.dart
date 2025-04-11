import 'package:ecinema_desktop/models/movie.dart';
import 'package:ecinema_desktop/providers/base_provider.dart';
import 'package:ecinema_desktop/providers/movie_provider.dart';
import 'package:ecinema_desktop/screens/movies_form_screen.dart';
import 'package:flutter/material.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({Key? key}) : super(key: key);

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final BaseProvider<Movie> _movieProvider = MovieProvider();

  List<Movie> _movies = [];
  bool _isLoading = true;
  int _currentPage = 1;
  int _pageSize = 10;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    try {
      setState(() => _isLoading = true);
      final result = await _movieProvider.get(
        filter: {
          "Title": _searchController.text,
          "Page": _currentPage - 1,
          "PageSize": _pageSize,
        },
      );
      setState(() {
        _movies = result.result;
        _totalCount = result.count ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading movies: $e");
    }
  }

  int get _totalPages => (_totalCount / _pageSize).ceil();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Traži film...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onSubmitted: (_) {
                      _currentPage = 1;
                      _loadMovies();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    _currentPage = 1;
                    _loadMovies();
                  },
                  icon: const Icon(Icons.search),
                  label: const Text("Pretraži"),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list),
                  label: const Text("Filteri"),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MovieFormScreen(),
                      ),
                    );
                    _loadMovies();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Dodaj novi film"),
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
                                  DataColumn(label: Text("STATUS")),
                                  DataColumn(label: Text("DATUM IZLASKA")),
                                  DataColumn(label: Text("TRAJANJE")),
                                  DataColumn(label: Text("JEZIK")),
                                  DataColumn(label: Text("PG OCJENA")),
                                  DataColumn(label: Text("AKCIJE")),
                                ],
                                rows: _buildMovieRows(),
                              ),
                            ),
                          );
                        },
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
                                    _loadMovies();
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
                                    _loadMovies();
                                  }
                                  : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<DataRow> _buildMovieRows() {
    return _movies.map((movie) {
      return DataRow(
        cells: [
          DataCell(
            Row(
              children: [
                const Icon(Icons.movie),
                const SizedBox(width: 8),
                Text(movie.title ?? ""),
              ],
            ),
          ),
          DataCell(_buildStatusBadge(movie.status ?? 0)),
          DataCell(
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 4),
                Text(
                  movie.releaseDate?.toIso8601String().split('T').first ?? "",
                ),
              ],
            ),
          ),
          DataCell(
            Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 4),
                Text("${movie.durationMinutes ?? 0} min"),
              ],
            ),
          ),
          DataCell(Text(movie.language ?? "")),
          DataCell(Text(_getPGRatingText(movie.pgRating))),
          DataCell(
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MovieFormScreen(movie: movie),
                      ),
                    );
                    _loadMovies();
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
                              "Da li ste sigurni da želite obrisati ovaj film?",
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
                        await _movieProvider.delete(movie.id!);
                        _loadMovies();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Film obrisan.")),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Greška pri brisanju filma: $e"),
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

  Widget _buildStatusBadge(int status) {
    String label;
    Color color;

    switch (status) {
      case 0:
        label = "Aktivan";
        color = Colors.green;
        break;
      case 1:
        label = "Uskoro";
        color = Colors.orange;
        break;
      default:
        label = "Nepoznat";
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _getPGRatingText(int? rating) {
    switch (rating) {
      case 0:
        return "PG-13";
      case 1:
        return "R";
      default:
        return "N/A";
    }
  }
}
