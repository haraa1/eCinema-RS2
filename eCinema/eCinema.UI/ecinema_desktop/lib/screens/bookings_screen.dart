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

  final _userIdController = TextEditingController();
  final _showtimeIdController = TextEditingController();
  final _discountCodeController = TextEditingController();
  DateTime? _bookingTimeFrom;
  DateTime? _bookingTimeTo;

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

  @override
  void dispose() {
    _userIdController.dispose();
    _showtimeIdController.dispose();
    _discountCodeController.dispose();
    super.dispose();
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

      if (_userIdController.text.trim().isNotEmpty) {
        final userId = int.tryParse(_userIdController.text.trim());
        if (userId != null) {
          filter["UserId"] = userId;
        }
      }
      if (_showtimeIdController.text.trim().isNotEmpty) {
        final showtimeId = int.tryParse(_showtimeIdController.text.trim());
        if (showtimeId != null) {
          filter["ShowtimeId"] = showtimeId;
        }
      }
      if (_discountCodeController.text.trim().isNotEmpty) {
        filter["DiscountCode"] = _discountCodeController.text.trim();
      }
      if (_bookingTimeFrom != null) {
        filter["BookingTimeFrom"] = _bookingTimeFrom!.toIso8601String();
      }
      if (_bookingTimeTo != null) {
        filter["BookingTimeTo"] = _bookingTimeTo!.toIso8601String();
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

  void _clearFilters() {
    setState(() {
      _userIdController.clear();
      _showtimeIdController.clear();
      _discountCodeController.clear();
      _bookingTimeFrom = null;
      _bookingTimeTo = null;
      _currentPage = 1;
    });
    _loadBookings();
  }

  Future<void> _selectDateTime(
    BuildContext context, {
    required bool isFrom,
  }) async {
    final initialDate =
        (isFrom ? _bookingTimeFrom : _bookingTimeTo) ?? DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    if (pickedTime == null) return;

    final finalDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      if (isFrom) {
        _bookingTimeFrom = finalDateTime;
      } else {
        _bookingTimeTo = finalDateTime;
      }
    });
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
            _buildFilterSection(),
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
                                        "ID Rezervacije",
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

  Widget _buildFilterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Filteri", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _buildFilterTextField(
              controller: _userIdController,
              hintText: "ID Korisnika...",
              icon: Icons.person_outline,
              keyboardType: TextInputType.number,
            ),
            _buildFilterTextField(
              controller: _showtimeIdController,
              hintText: "ID Projekcije...",
              icon: Icons.theaters,
              keyboardType: TextInputType.number,
            ),
            _buildFilterTextField(
              controller: _discountCodeController,
              hintText: "Popust kod...",
              icon: Icons.discount_outlined,
            ),
            _buildDatePicker(
              hintText: 'Rezervacija od...',
              date: _bookingTimeFrom,
              onPressed: () => _selectDateTime(context, isFrom: true),
            ),
            _buildDatePicker(
              hintText: 'Rezervacija do...',
              date: _bookingTimeTo,
              onPressed: () => _selectDateTime(context, isFrom: false),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() => _currentPage = 1);
                      _loadBookings();
                    },
                    icon: const Icon(Icons.search),
                    label: const Text("Pretraži"),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 48,
                  child: TextButton(
                    onPressed: _clearFilters,
                    child: const Text("Očisti filtere"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return SizedBox(
      width: 220,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon),
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
        keyboardType: keyboardType,
        onSubmitted: (_) {
          _currentPage = 1;
          _loadBookings();
        },
      ),
    );
  }

  Widget _buildDatePicker({
    required String hintText,
    required DateTime? date,
    required VoidCallback onPressed,
  }) {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    return SizedBox(
      width: 220,
      height: 48,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.grey.shade600, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  date != null ? dateFormat.format(date) : hintText,
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        date != null
                            ? Theme.of(context).textTheme.bodyLarge?.color
                            : Theme.of(context).hintColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
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
