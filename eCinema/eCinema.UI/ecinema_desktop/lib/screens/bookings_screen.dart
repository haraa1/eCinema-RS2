import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ecinema_desktop/models/booking.dart';
import 'package:ecinema_desktop/providers/booking_provider.dart';

class BookingListScreen extends StatefulWidget {
  const BookingListScreen({super.key});

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  final _bookingProvider = BookingProvider();
  final _searchIdController = TextEditingController();

  List<Booking> _bookings = [];
  int _currentPage = 1;
  final int _pageSize = 15;
  int _totalCount = 0;

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings({bool showLoading = true}) async {
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
      };

      if (_searchIdController.text.trim().isNotEmpty) {
        final bookingId = int.tryParse(_searchIdController.text.trim());
        if (bookingId != null) {
          filter["Id"] = bookingId;
        }
      }

      final result = await _bookingProvider.get(filter: filter);
      if (mounted) {
        setState(() {
          _bookings = result.result;
          _totalCount = result.count ?? 0;
        });
      }
    } catch (e) {
      print("Error loading bookings: $e");
      if (mounted) {
        _error = "Greška pri učitavanju rezervacija: ${e.toString()}";
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  int get _totalPages => _totalCount > 0 ? (_totalCount / _pageSize).ceil() : 1;

  Future<void> _deleteBooking(int bookingId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Potvrdite brisanje"),
            content: const Text(
              "Da li ste sigurni da želite obrisati ovu rezervaciju? Ova akcija se ne može poništiti.",
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
        await _bookingProvider.delete(bookingId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Rezervacija uspješno obrisana."),
              backgroundColor: Colors.green,
            ),
          );
          if (_bookings.length == 1 && _currentPage > 1) {
            _currentPage--;
          }
          _loadBookings(showLoading: false);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Greška pri brisanju rezervacije: ${e.toString()}"),
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
                    controller: _searchIdController,
                    decoration: InputDecoration(
                      hintText: "Pretraži po ID rezervacije...",
                      prefixIcon: const Icon(Icons.vpn_key),
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
                    keyboardType: TextInputType.number,
                    onSubmitted: (_) {
                      _currentPage = 1;
                      _loadBookings();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    _currentPage = 1;
                    _loadBookings();
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
            else if (_bookings.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    "Nema pronađenih rezervacija.",
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
                                        "KORISNIK (ID Rez.)",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        "PROJEKCIJA (ID)",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        "VRIJEME REZ.",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        "POPUST KOD",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        "BR. KARATA",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        "BR. KONCESIJA",
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
                                  rows: _bookings.map(_buildRow).toList(),
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
                                        _loadBookings();
                                      }
                                      : null,
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed:
                                  _currentPage > 1
                                      ? () {
                                        setState(() => _currentPage--);
                                        _loadBookings();
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
                                        _loadBookings();
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
                                        _loadBookings();
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

  DataRow _buildRow(Booking booking) {
    final bookingTimeFormatted = DateFormat(
      'dd.MM.yyyy HH:mm',
    ).format(booking.bookingTime);
    final ticketsCount = booking.tickets.length;
    final concessionsCount = booking.bookingConcessions.length;

    return DataRow(
      cells: [
        DataCell(Text(booking.id.toString())),
        DataCell(Text(booking.showtimeId.toString())),
        DataCell(Text(bookingTimeFormatted)),
        DataCell(
          Text(
            booking.discountCode?.isNotEmpty == true
                ? booking.discountCode!
                : "-",
          ),
        ),
        DataCell(Text(ticketsCount.toString())),
        DataCell(Text(concessionsCount.toString())),
        DataCell(
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            tooltip: "Otkaži/Obriši rezervaciju",
            onPressed: () => _deleteBooking(booking.id),
          ),
        ),
      ],
    );
  }
}
