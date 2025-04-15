import 'package:flutter/material.dart';
import 'package:ecinema_desktop/models/user.dart';
import 'package:ecinema_desktop/models/role.dart';
import 'package:ecinema_desktop/providers/user_provider.dart';
import 'package:ecinema_desktop/providers/role_provider.dart';
import 'package:ecinema_desktop/screens/user_form_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final _searchController = TextEditingController();
  final _userProvider = UserProvider();
  final _roleProvider = RoleProvider();

  List<User> _users = [];
  Map<int, String> _roleMap = {};
  bool _isLoading = true;
  int _currentPage = 1;
  int _pageSize = 10;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _loadRoles().then((_) => _loadUsers());
  }

  Future<void> _loadRoles() async {
    final result = await _roleProvider.get();
    setState(() {
      _roleMap = {for (var r in result.result) r.id!: r.name!};
    });
  }

  Future<void> _loadUsers() async {
    try {
      setState(() => _isLoading = true);
      final result = await _userProvider.get(
        filter: {
          "UserName": _searchController.text,
          "Page": _currentPage - 1,
          "PageSize": _pageSize,
        },
      );
      setState(() {
        _users = result.result;
        _totalCount = result.count ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading users: $e");
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
                      hintText: "Traži korisnika...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onSubmitted: (_) {
                      _currentPage = 1;
                      _loadUsers();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    _currentPage = 1;
                    _loadUsers();
                  },
                  icon: const Icon(Icons.search),
                  label: const Text("Pretraži"),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const UserFormScreen()),
                    );
                    _loadUsers();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Dodaj korisnika"),
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
                                  DataColumn(label: Text("USERNAME")),
                                  DataColumn(label: Text("EMAIL")),
                                  DataColumn(label: Text("TELEFON")),
                                  DataColumn(label: Text("ULOGE")),
                                  DataColumn(label: Text("AKCIJE")),
                                ],
                                rows: _users.map(_buildRow).toList(),
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
                                    _loadUsers();
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
                                    _loadUsers();
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

  DataRow _buildRow(User u) {
    String roleNames = u.roles?.join(", ") ?? "";

    return DataRow(
      cells: [
        DataCell(Text(u.userName ?? "")),
        DataCell(Text(u.email ?? "")),
        DataCell(Text(u.phoneNumber ?? "")),
        DataCell(Text(roleNames)),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => UserFormScreen(user: u)),
                  );
                  _loadUsers();
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
                            "Da li ste sigurni da želite obrisati ovog korisnika?",
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
                    await _userProvider.delete(u.id!);
                    _loadUsers();
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
