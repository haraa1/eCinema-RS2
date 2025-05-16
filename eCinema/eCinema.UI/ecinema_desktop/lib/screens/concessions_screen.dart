import 'package:ecinema_desktop/screens/concession_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:ecinema_desktop/models/concession.dart';
import 'package:ecinema_desktop/providers/concession_provider.dart';

class ConcessionListScreen extends StatefulWidget {
  const ConcessionListScreen({super.key});

  @override
  State<ConcessionListScreen> createState() => _ConcessionListScreenState();
}

class _ConcessionListScreenState extends State<ConcessionListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ConcessionProvider _concessionProvider = ConcessionProvider();

  List<Concession> _concessions = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  int _pageSize = 10;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _loadConcessions();
  }

  Future<void> _loadConcessions({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    try {
      final result = await _concessionProvider.get(
        filter: {
          "Name": _searchController.text.trim(),
          "Page": _currentPage - 1,
          "PageSize": _pageSize,
        },
      );
      if (mounted) {
        setState(() {
          _concessions = result.result;
          _totalCount = result.count ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading concessions: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = "Greška pri učitavanju proizvoda: ${e.toString()}";
        });
      }
    }
  }

  int get _totalPages => _totalCount > 0 ? (_totalCount / _pageSize).ceil() : 1;

  void _navigateToConcessionForm({Concession? concession}) async {
    final bool? shouldRefresh = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => ConcessionFormScreen(concession: concession),
      ),
    );
    if (shouldRefresh == true && mounted) {
      _loadConcessions();
    }
  }

  Future<void> _deleteConcession(int concessionId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Potvrda brisanja"),
            content: const Text(
              "Da li ste sigurni da želite obrisati ovaj proizvod? Ova akcija se ne može poništiti.",
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
        await _concessionProvider.delete(concessionId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Proizvod uspješno obrisan."),
              backgroundColor: Colors.green,
            ),
          );
          if (_concessions.length == 1 && _currentPage > 1) {
            _currentPage--;
          }
          _loadConcessions(showLoading: false);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Greška pri brisanju proizvoda: ${e.toString()}"),
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
                      hintText: "Pretraži po nazivu proizvoda...",
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
                      _loadConcessions();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    _currentPage = 1;
                    _loadConcessions();
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
                  onPressed: () => _navigateToConcessionForm(),
                  icon: const Icon(Icons.add),
                  label: const Text("Dodaj proizvod"),
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
            else if (_concessions.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    "Nema pronađenih proizvoda.",
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
                                        "NAZIV",
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
                                        "OPIS",
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
                                        _loadConcessions();
                                      }
                                      : null,
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed:
                                  _currentPage > 1
                                      ? () {
                                        setState(() => _currentPage--);
                                        _loadConcessions();
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
                                        _loadConcessions();
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
                                        _loadConcessions();
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
    return _concessions.map((concession) {
      return DataRow(
        cells: [
          DataCell(Text(concession.id?.toString() ?? 'N/A')),
          DataCell(Text(concession.name ?? "Nepoznat naziv")),
          DataCell(Text(concession.price?.toStringAsFixed(2) ?? "-")),
          DataCell(
            Tooltip(
              message: concession.description ?? "",
              child: SizedBox(
                width: 150,
                child: Text(
                  concession.description ?? "-",
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                  tooltip: "Uredi proizvod",
                  onPressed:
                      () => _navigateToConcessionForm(concession: concession),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  tooltip: "Obriši proizvod",
                  onPressed: () => _deleteConcession(concession.id!),
                ),
              ],
            ),
          ),
        ],
      );
    }).toList();
  }
}
