import 'package:ecinema_desktop/screens/discount_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ecinema_desktop/models/discount.dart';
import 'package:ecinema_desktop/providers/discount_provider.dart';

class DiscountListScreen extends StatefulWidget {
  const DiscountListScreen({super.key});

  @override
  State<DiscountListScreen> createState() => _DiscountListScreenState();
}

class _DiscountListScreenState extends State<DiscountListScreen> {
  final _discountProvider = DiscountProvider();
  final _searchCodeController = TextEditingController();

  List<Discount> _discounts = [];
  int _currentPage = 1;
  final int _pageSize = 10;
  int _totalCount = 0;

  bool _isLoading = true;
  String? _error;
  bool? _filterIsActive;

  @override
  void initState() {
    super.initState();
    _loadDiscounts();
  }

  Future<void> _loadDiscounts({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    try {
      Map<String, dynamic> filter = {
        "Page": _currentPage - 1,
        "PageSize": _pageSize,
        "Name": _searchCodeController.text.trim(),
      };
      if (_filterIsActive != null) {
        filter["IsActive"] = _filterIsActive;
      }

      final result = await _discountProvider.get(filter: filter);
      if (mounted) {
        setState(() {
          _discounts = result.result;
          _totalCount = result.count ?? 0;
        });
      }
    } catch (e) {
      print("Error loading discounts: $e");
      if (mounted) {
        _error = "Greška pri učitavanju popusta: ${e.toString()}";
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  int get _totalPages => _totalCount > 0 ? (_totalCount / _pageSize).ceil() : 1;

  void _navigateToForm({Discount? discount}) async {
    final bool? shouldRefresh = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => DiscountFormScreen(discount: discount)),
    );
    if (shouldRefresh == true && mounted) {
      _loadDiscounts();
    }
  }

  Future<void> _deleteDiscount(int discountId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Potvrda brisanja"),
            content: const Text(
              "Da li ste sigurni da želite obrisati ovaj popust?",
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
        await _discountProvider.delete(discountId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Popust uspješno obrisan."),
              backgroundColor: Colors.green,
            ),
          );
          if (_discounts.length == 1 && _currentPage > 1) {
            _currentPage--;
          }
          _loadDiscounts(showLoading: false);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Greška pri brisanju popusta: ${e.toString()}"),
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
                    controller: _searchCodeController,
                    decoration: InputDecoration(
                      hintText: "Pretraži po kodu popusta...",
                      prefixIcon: const Icon(Icons.sell_outlined),
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
                      _loadDiscounts();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<bool?>(
                  value: _filterIsActive,
                  hint: const Text("Status aktivnosti"),
                  items: const [
                    DropdownMenuItem(value: null, child: Text("Svi statusi")),
                    DropdownMenuItem(value: true, child: Text("Aktivni")),
                    DropdownMenuItem(value: false, child: Text("Neaktivni")),
                  ],
                  onChanged: (bool? newValue) {
                    setState(() {
                      _filterIsActive = newValue;
                      _currentPage = 1;
                    });
                    _loadDiscounts();
                  },
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    _currentPage = 1;
                    _loadDiscounts();
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
                  onPressed: () => _navigateToForm(),
                  icon: const Icon(Icons.add),
                  label: const Text("Dodaj popust"),
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
            else if (_discounts.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    "Nema pronađenih popusta za odabrane kriterije.",
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
                                  columnSpacing: 15,
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
                                        "KOD",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        "PROCENT (%)",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        "VAŽI OD",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        "VAŽI DO",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        "AKTIVAN",
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
                                  rows: _discounts.map(_buildRow).toList(),
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
                                        _loadDiscounts();
                                      }
                                      : null,
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed:
                                  _currentPage > 1
                                      ? () {
                                        setState(() => _currentPage--);
                                        _loadDiscounts();
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
                                        _loadDiscounts();
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
                                        _loadDiscounts();
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

  DataRow _buildRow(Discount discount) {
    final DateFormat dateFormatter = DateFormat('dd.MM.yyyy');
    return DataRow(
      cells: [
        DataCell(Text(discount.id.toString())),
        DataCell(Text(discount.code)),
        DataCell(Text(discount.discountPercentage.toStringAsFixed(0))),
        DataCell(Text(dateFormatter.format(discount.validFrom))),
        DataCell(Text(dateFormatter.format(discount.validTo))),
        DataCell(
          Icon(
            discount.isActive ? Icons.check_circle : Icons.cancel,
            color: discount.isActive ? Colors.green : Colors.red,
            semanticLabel: discount.isActive ? "Aktivan" : "Neaktivan",
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                tooltip: "Uredi popust",
                onPressed: () => _navigateToForm(discount: discount),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                tooltip: "Obriši popust",
                onPressed: () => _deleteDiscount(discount.id),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
