import 'package:ecinema_desktop/models/concession.dart';
import 'package:ecinema_desktop/providers/concession_provider.dart';
import 'package:ecinema_desktop/screens/concession_form_screen.dart';
import 'package:flutter/material.dart';

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
  int _currentPage = 1;
  int _pageSize = 10;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _loadConcessions();
  }

  Future<void> _loadConcessions() async {
    try {
      setState(() => _isLoading = true);
      final result = await _concessionProvider.get(
        filter: {
          "Name": _searchController.text,
          "Page": _currentPage - 1,
          "PageSize": _pageSize,
        },
      );
      setState(() {
        _concessions = result.result;
        _totalCount = result.count ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading concessions: $e");
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
                      hintText: "Traži proizvod...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onSubmitted: (_) {
                      _currentPage = 1;
                      _loadConcessions();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    _currentPage = 1;
                    _loadConcessions();
                  },
                  icon: const Icon(Icons.search),
                  label: const Text("Pretraži"),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ConcessionFormScreen(),
                      ),
                    );
                    _loadConcessions();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Dodaj proizvod"),
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
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text("NAZIV")),
                            DataColumn(label: Text("CIJENA")),
                            DataColumn(label: Text("OPIS")),
                            DataColumn(label: Text("AKCIJE")),
                          ],
                          rows: _buildRows(),
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
                                    _loadConcessions();
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
                                    _loadConcessions();
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

  List<DataRow> _buildRows() {
    return _concessions.map((c) {
      return DataRow(
        cells: [
          DataCell(Text(c.name ?? "")),
          DataCell(Text(c.price?.toStringAsFixed(2) ?? "")),
          DataCell(Text(c.description ?? "")),
          DataCell(
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (context) => ConcessionFormScreen(concession: c),
                      ),
                    );
                    _loadConcessions();
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
                              "Da li ste sigurni da želite obrisati ovaj proizvod?",
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
                        await _concessionProvider.delete(c.id!);
                        _loadConcessions();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Proizvod obrisan.")),
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
