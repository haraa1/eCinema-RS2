import 'package:ecinema_desktop/screens/genres_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:ecinema_desktop/models/genre.dart';
import 'package:ecinema_desktop/providers/genre_provider.dart';

class GenreListScreen extends StatefulWidget {
  const GenreListScreen({super.key});

  @override
  _GenreListScreenState createState() => _GenreListScreenState();
}

class _GenreListScreenState extends State<GenreListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GenreProvider _genreProvider = GenreProvider();

  List<Genre> _genres = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  final int _pageSize = 10;
  int _totalCount = 0;

  int get _totalPages => _totalCount > 0 ? (_totalCount / _pageSize).ceil() : 1;

  @override
  void initState() {
    super.initState();
    _loadGenres();
  }

  Future<void> _loadGenres({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    try {
      final result = await _genreProvider.get(
        filter: {
          "Name": _searchController.text.trim(),
          "Page": _currentPage - 1,
          "PageSize": _pageSize,
        },
      );
      if (mounted) {
        setState(() {
          _genres = result.result;
          _totalCount = result.count ?? 0;
        });
      }
    } catch (e) {
      debugPrint("Error loading genres: $e");
      if (mounted) {
        setState(() {
          _error = "Greška pri učitavanju žanrova: ${e.toString()}";
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToForm({Genre? genre}) async {
    final bool? shouldRefresh = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => GenreFormScreen(genre: genre)),
    );

    if (shouldRefresh == true && mounted) {
      _loadGenres();
    }
  }

  Future<void> _deleteGenre(int genreId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Potvrda brisanja"),
            content: const Text(
              "Da li ste sigurni da želite obrisati ovaj žanr? Može biti povezan s filmovima.",
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
        await _genreProvider.delete(genreId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Žanr uspješno obrisan."),
              backgroundColor: Colors.green,
            ),
          );
          if (_genres.length == 1 && _currentPage > 1) {
            _currentPage--;
          }
          _loadGenres(showLoading: false);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Greška pri brisanju žanra: ${e.toString()}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
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
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Pretraži po nazivu žanra...",
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
                      _loadGenres();
                    },
                  ),
                ),

                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => _navigateToForm(),
                  icon: const Icon(Icons.add),
                  label: const Text("Dodaj žanr"),
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
            else if (_genres.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    "Nema pronađenih žanrova.",
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
                                  columnSpacing: 20,
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
                                        "NAZIV ŽANRA",
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
                                  rows: _buildGenreRows(),
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
                                        _loadGenres();
                                      }
                                      : null,
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed:
                                  _currentPage > 1
                                      ? () {
                                        setState(() => _currentPage--);
                                        _loadGenres();
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
                                        _loadGenres();
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
                                        _loadGenres();
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

  List<DataRow> _buildGenreRows() {
    return _genres.map((genre) {
      return DataRow(
        cells: [
          DataCell(Text(genre.id?.toString() ?? 'N/A')),
          DataCell(Text(genre.name ?? "Nepoznat naziv")),
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                  tooltip: "Uredi žanr",
                  onPressed: () => _navigateToForm(genre: genre),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  tooltip: "Obriši žanr",
                  onPressed: () => _deleteGenre(genre.id!),
                ),
              ],
            ),
          ),
        ],
      );
    }).toList();
  }
}
