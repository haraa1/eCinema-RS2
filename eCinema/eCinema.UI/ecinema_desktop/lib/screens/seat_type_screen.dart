import 'package:ecinema_desktop/screens/seat_type_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:ecinema_desktop/models/seat_type.dart';
import 'package:ecinema_desktop/providers/seat_type_provider.dart';

class SeatTypeListScreen extends StatefulWidget {
  const SeatTypeListScreen({super.key});

  @override
  State<SeatTypeListScreen> createState() => _SeatTypeListScreenState();
}

class _SeatTypeListScreenState extends State<SeatTypeListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SeatTypeProvider _seatTypeProvider = SeatTypeProvider();

  List<SeatType> _seatTypes = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  final int _pageSize = 10;
  int _totalCount = 0;

  int get _totalPages => _totalCount > 0 ? (_totalCount / _pageSize).ceil() : 1;

  @override
  void initState() {
    super.initState();
    _loadSeatTypes();
  }

  Future<void> _loadSeatTypes({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    try {
      final result = await _seatTypeProvider.get(
        filter: {
          "Name": _searchController.text.trim(),
          "Page": _currentPage - 1,
          "PageSize": _pageSize,
        },
      );
      if (mounted) {
        setState(() {
          _seatTypes = result.result;
          _totalCount = result.count ?? 0;
        });
      }
    } catch (e) {
      print("Error loading seat types: $e");
      if (mounted) {
        setState(() {
          _error = "Greška pri učitavanju vrsta sjedala: ${e.toString()}";
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToForm({SeatType? seatType}) async {
    final bool? shouldRefresh = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => SeatTypeFormScreen(seatType: seatType)),
    );
    if (shouldRefresh == true && mounted) {
      _loadSeatTypes();
    }
  }

  Future<void> _deleteSeatType(int seatTypeId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Potvrda brisanja'),
            content: const Text(
              'Da li ste sigurni da želite obrisati ovu vrstu sjedala? Može biti u upotrebi u dvoranama.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Otkaži'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Obriši',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm == true && mounted) {
      try {
        await _seatTypeProvider.delete(seatTypeId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vrsta sjedala uspješno obrisana.'),
              backgroundColor: Colors.green,
            ),
          );
          if (_seatTypes.length == 1 && _currentPage > 1) {
            _currentPage--;
          }
          _loadSeatTypes(showLoading: false);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Greška pri brisanju: ${e.toString()}'),
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
                      hintText: 'Pretraži po nazivu vrste sjedala...',
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
                      _loadSeatTypes();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => _navigateToForm(),
                  icon: const Icon(Icons.add),
                  label: const Text('Dodaj vrstu'),
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
            else if (_seatTypes.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    "Nema pronađenih vrsta sjedala.",
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
                                        'ID',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'NAZIV',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'MULTIPLIKATOR CIJENE',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'AKCIJE',
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
                                        _loadSeatTypes();
                                      }
                                      : null,
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed:
                                  _currentPage > 1
                                      ? () {
                                        setState(() => _currentPage--);
                                        _loadSeatTypes();
                                      }
                                      : null,
                            ),
                            Text('Stranica $_currentPage od $_totalPages'),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed:
                                  _currentPage < _totalPages
                                      ? () {
                                        setState(() => _currentPage++);
                                        _loadSeatTypes();
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
                                        _loadSeatTypes();
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
    return _seatTypes.map((seatType) {
      return DataRow(
        cells: [
          DataCell(Text(seatType.id?.toString() ?? 'N/A')),
          DataCell(Text(seatType.name ?? "Nepoznat naziv")),
          DataCell(Text(seatType.priceMultiplier?.toStringAsFixed(2) ?? "-")),
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                  tooltip: "Uredi vrstu sjedala",
                  onPressed: () => _navigateToForm(seatType: seatType),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  tooltip: "Obriši vrstu sjedala",
                  onPressed: () => _deleteSeatType(seatType.id!),
                ),
              ],
            ),
          ),
        ],
      );
    }).toList();
  }
}
