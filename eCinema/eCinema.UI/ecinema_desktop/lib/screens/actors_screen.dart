import 'package:ecinema_desktop/models/actor.dart';
import 'package:ecinema_desktop/providers/actor_provider.dart';
import 'package:ecinema_desktop/screens/actors_form_screen.dart';
import 'package:flutter/material.dart';

class ActorListScreen extends StatefulWidget {
  const ActorListScreen({super.key});

  @override
  State<ActorListScreen> createState() => _ActorListScreenState();
}

class _ActorListScreenState extends State<ActorListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ActorProvider _actorProvider = ActorProvider();

  List<Actor> _actors = [];
  bool _isLoading = true;
  int _currentPage = 1;
  int _pageSize = 10;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _loadActors();
  }

  Future<void> _loadActors() async {
    try {
      setState(() => _isLoading = true);
      final result = await _actorProvider.get(
        filter: {
          "Name": _searchController.text,
          "Page": _currentPage - 1,
          "PageSize": _pageSize,
        },
      );
      setState(() {
        _actors = result.result;
        _totalCount = result.count ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading actors: $e");
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
                      hintText: "Traži glumca...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onSubmitted: (_) {
                      _currentPage = 1;
                      _loadActors();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    _currentPage = 1;
                    _loadActors();
                  },
                  icon: const Icon(Icons.search),
                  label: const Text("Pretraži"),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ActorFormScreen(),
                      ),
                    );
                    _loadActors();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Dodaj novog glumca"),
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
                            DataColumn(label: Text("IME")),
                            DataColumn(label: Text("PREZIME")),
                            DataColumn(label: Text("AKCIJE")),
                          ],
                          rows: _buildActorRows(),
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
                                    _loadActors();
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
                                    _loadActors();
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

  List<DataRow> _buildActorRows() {
    return _actors.map((actor) {
      return DataRow(
        cells: [
          DataCell(Text(actor.firstName ?? "")),
          DataCell(Text(actor.lastName ?? "")),
          DataCell(
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ActorFormScreen(actor: actor),
                      ),
                    );
                    _loadActors();
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
                              "Da li ste sigurni da želite obrisati ovog glumca?",
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
                        await _actorProvider.delete(actor.id!);
                        _loadActors();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Glumac obrisan.")),
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
