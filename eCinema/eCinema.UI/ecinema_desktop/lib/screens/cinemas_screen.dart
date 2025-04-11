import 'package:ecinema_desktop/models/cinema.dart';
import 'package:ecinema_desktop/providers/cinema_provider.dart';
import 'package:ecinema_desktop/screens/cinemas_form_screen.dart';
import 'package:flutter/material.dart';

class CinemaListScreen extends StatefulWidget {
  const CinemaListScreen({super.key});

  @override
  State<CinemaListScreen> createState() => _CinemaListScreenState();
}

class _CinemaListScreenState extends State<CinemaListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final CinemaProvider _cinemaProvider = CinemaProvider();

  List<Cinema> _cinemas = [];
  bool _isLoading = true;
  int _currentPage = 1;
  int _pageSize = 10;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCinemas();
  }

  Future<void> _loadCinemas() async {
    try {
      setState(() => _isLoading = true);
      final result = await _cinemaProvider.get(
        filter: {
          "City": _searchController.text,
          "Page": _currentPage - 1,
          "PageSize": _pageSize,
        },
      );
      setState(() {
        _cinemas = result.result;
        _totalCount = result.count ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading cinemas: $e");
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
                      hintText: "Traži kino...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onSubmitted: (_) {
                      _currentPage = 1;
                      _loadCinemas();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    _currentPage = 1;
                    _loadCinemas();
                  },
                  icon: const Icon(Icons.search),
                  label: const Text("Pretraži"),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CinemaFormScreen(),
                      ),
                    );
                    _loadCinemas();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Dodaj kino"),
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
                                  DataColumn(label: Text("NAZIV")),
                                  DataColumn(label: Text("GRAD")),
                                  DataColumn(label: Text("ADRESA")),
                                  DataColumn(label: Text("AKCIJE")),
                                ],
                                rows: _buildCinemaRows(),
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
                                    _loadCinemas();
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
                                    _loadCinemas();
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

  List<DataRow> _buildCinemaRows() {
    return _cinemas.map((cinema) {
      return DataRow(
        cells: [
          DataCell(Text(cinema.name ?? "")),
          DataCell(Text(cinema.city ?? "")),
          DataCell(Text(cinema.address ?? "")),
          DataCell(
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CinemaFormScreen(cinema: cinema),
                      ),
                    );
                    _loadCinemas();
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
                              "Da li ste sigurni da želite obrisati ovo kino?",
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
                        await _cinemaProvider.delete(cinema.id!);
                        _loadCinemas();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Kino obrisano.")),
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
