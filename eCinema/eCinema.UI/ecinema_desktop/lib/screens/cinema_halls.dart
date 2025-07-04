import 'package:ecinema_desktop/screens/cinema_hall_form_screen.dart';
import 'package:ecinema_desktop/screens/cinema_hall_seats_screen.dart';
import 'package:flutter/material.dart';
import 'package:ecinema_desktop/models/cinema_hall.dart';
import 'package:ecinema_desktop/providers/cinema_hall_provider.dart';

class CinemaHallListScreen extends StatefulWidget {
  const CinemaHallListScreen({super.key});

  @override
  State<CinemaHallListScreen> createState() => _CinemaHallListScreenState();
}

class _CinemaHallListScreenState extends State<CinemaHallListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final CinemaHallProvider _cinemaHallProvider = CinemaHallProvider();

  List<CinemaHall> _cinemaHalls = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  int _pageSize = 10;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCinemaHalls();
  }

  Future<void> _loadCinemaHalls({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    try {
      final result = await _cinemaHallProvider.get(
        filter: {
          "Name": _searchController.text.trim(),
          "Page": _currentPage - 1,
          "PageSize": _pageSize,
        },
      );
      if (mounted) {
        setState(() {
          _cinemaHalls = result.result;
          _totalCount = result.count ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading cinema halls: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = "Greška pri učitavanju dvorana: ${e.toString()}";
        });
      }
    }
  }

  int get _totalPages => _totalCount > 0 ? (_totalCount / _pageSize).ceil() : 1;

  void _navigateToCinemaHallForm({CinemaHall? cinemaHall}) async {
    final bool? shouldRefresh = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CinemaHallFormScreen(cinemaHall: cinemaHall),
      ),
    );
    if (shouldRefresh == true && mounted) {
      _loadCinemaHalls();
    }
  }

  void _navigateToCinemaHallSeatsScreen(int cinemaHallId) async {
    final bool? shouldRefresh = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CinemaHallSeatsScreen(cinemaHallId: cinemaHallId),
      ),
    );
    if (shouldRefresh == true && mounted) {
      _loadCinemaHalls();
    }
  }

  Future<void> _deleteCinemaHall(int cinemaHallId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Potvrda brisanja"),
            content: const Text(
              "Da li ste sigurni da želite obrisati ovu dvoranu? Sve povezane projekcije i sjedišta će također biti pogođeni.",
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
        await _cinemaHallProvider.delete(cinemaHallId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Dvorana uspješno obrisana."),
              backgroundColor: Colors.green,
            ),
          );
          if (_cinemaHalls.length == 1 && _currentPage > 1) {
            _currentPage--;
          }
          _loadCinemaHalls(showLoading: false);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Greška pri brisanju dvorane: ${e.toString()}"),
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
                      hintText: "Pretraži dvorane po nazivu...",
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
                      _loadCinemaHalls();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    _currentPage = 1;
                    _loadCinemaHalls();
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
                  onPressed: () => _navigateToCinemaHallForm(),
                  icon: const Icon(Icons.add),
                  label: const Text("Dodaj dvoranu"),
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
            else if (_cinemaHalls.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    "Nema pronađenih dvorana.",
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
                                        "NAZIV DVORANE",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        "KAPACITET",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        "KINO",
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
                                  rows: _cinemaHalls.map(_buildRow).toList(),
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
                                        _loadCinemaHalls();
                                      }
                                      : null,
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed:
                                  _currentPage > 1
                                      ? () {
                                        setState(() => _currentPage--);
                                        _loadCinemaHalls();
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
                                        _loadCinemaHalls();
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
                                        _loadCinemaHalls();
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

  DataRow _buildRow(CinemaHall hall) {
    return DataRow(
      cells: [
        DataCell(Text(hall.id?.toString() ?? 'N/A')),
        DataCell(Text(hall.name ?? "Nepoznat naziv")),
        DataCell(Text(hall.capacity?.toString() ?? "-")),
        DataCell(Text(hall.cinemaName ?? "N/A")),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                tooltip: "Uredi dvoranu",
                onPressed: () => _navigateToCinemaHallForm(cinemaHall: hall),
              ),
              IconButton(
                icon: Icon(Icons.event_seat, color: Colors.teal),
                tooltip: "Uredi raspored sjedišta",
                onPressed: () => _navigateToCinemaHallSeatsScreen(hall.id!),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                tooltip: "Obriši dvoranu",
                onPressed: () => _deleteCinemaHall(hall.id!),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
