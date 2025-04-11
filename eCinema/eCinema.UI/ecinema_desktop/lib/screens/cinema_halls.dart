import 'package:flutter/material.dart';
import 'package:ecinema_desktop/models/cinema_hall.dart';
import 'package:ecinema_desktop/providers/cinema_hall_provider.dart';
import 'package:ecinema_desktop/screens/cinema_hall_form_screen.dart';
import 'package:ecinema_desktop/screens/cinema_hall_seats_screen.dart';

class CinemaHallListScreen extends StatefulWidget {
  const CinemaHallListScreen({super.key});

  @override
  State<CinemaHallListScreen> createState() => _CinemaHallListScreenState();
}

class _CinemaHallListScreenState extends State<CinemaHallListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final CinemaHallProvider _provider = CinemaHallProvider();

  List<CinemaHall> _cinemaHalls = [];
  bool _isLoading = true;
  int _currentPage = 1;
  int _pageSize = 10;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCinemaHalls();
  }

  Future<void> _loadCinemaHalls() async {
    setState(() => _isLoading = true);
    try {
      final result = await _provider.get(
        filter: {
          "Name": _searchController.text,
          "Page": _currentPage - 1,
          "PageSize": _pageSize,
        },
      );
      setState(() {
        _cinemaHalls = result.result;
        _totalCount = result.count ?? 0;
      });
    } catch (e) {
      print("Error loading cinema halls: $e");
    }
    setState(() => _isLoading = false);
  }

  int get _totalPages => (_totalCount / _pageSize).ceil();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search field and controls
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Traži dvoranu...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onSubmitted: (_) {
                      _currentPage = 1;
                      _loadCinemaHalls();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    _currentPage = 1;
                    _loadCinemaHalls();
                  },
                  icon: const Icon(Icons.search),
                  label: const Text("Pretraži"),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CinemaHallFormScreen(),
                      ),
                    );
                    _loadCinemaHalls();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Dodaj dvoranu"),
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
                                  DataColumn(label: Text("KAPACITET")),
                                  DataColumn(label: Text("AKCIJE")),
                                ],
                                rows: _cinemaHalls.map(_buildRow).toList(),
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
                                    _loadCinemaHalls();
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
                                    _loadCinemaHalls();
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

  DataRow _buildRow(CinemaHall hall) {
    return DataRow(
      cells: [
        DataCell(Text(hall.name ?? "")),
        DataCell(Text(hall.capacity?.toString() ?? "-")),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CinemaHallFormScreen(cinemaHall: hall),
                    ),
                  );
                  _loadCinemaHalls();
                },
              ),
              IconButton(
                icon: const Icon(Icons.event_seat),
                tooltip: "Uredi raspored sjedišta",
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) => CinemaHallSeatsScreen(cinemaHallId: hall.id!),
                    ),
                  );
                  _loadCinemaHalls();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
