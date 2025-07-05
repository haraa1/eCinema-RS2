import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ecinema_desktop/models/payment.dart';
import 'package:ecinema_desktop/providers/payment_provider.dart';

enum PaymentStatusEnum { Pending, Succeeded, Failed, Refunded }

String getPaymentStatusName(int? statusValue) {
  if (statusValue == null) return "Nepoznat";
  if (statusValue >= 0 && statusValue < PaymentStatusEnum.values.length) {
    switch (PaymentStatusEnum.values[statusValue]) {
      case PaymentStatusEnum.Pending:
        return "Na čekanju";
      case PaymentStatusEnum.Succeeded:
        return "Uspjelo";
      case PaymentStatusEnum.Failed:
        return "Neuspjelo";
      case PaymentStatusEnum.Refunded:
        return "Vraćeno";
    }
  }
  return "Nepoznat ($statusValue)";
}

class PaymentListScreen extends StatefulWidget {
  const PaymentListScreen({super.key});

  @override
  State<PaymentListScreen> createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends State<PaymentListScreen> {
  final _paymentProvider = PaymentProvider();

  List<Payment> _payments = [];
  int _currentPage = 1;
  final int _pageSize = 15;
  int _totalCount = 0;

  bool _isLoading = true;
  String? _error;
  int? _selectedStatusFilter;

  final Map<int?, String> _paymentStatusOptions = {
    null: "Svi statusi",
    PaymentStatusEnum.Pending.index: getPaymentStatusName(
      PaymentStatusEnum.Pending.index,
    ),
    PaymentStatusEnum.Succeeded.index: getPaymentStatusName(
      PaymentStatusEnum.Succeeded.index,
    ),
    PaymentStatusEnum.Failed.index: getPaymentStatusName(
      PaymentStatusEnum.Failed.index,
    ),
    PaymentStatusEnum.Refunded.index: getPaymentStatusName(
      PaymentStatusEnum.Refunded.index,
    ),
  };

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments({bool showLoading = true}) async {
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

      if (_selectedStatusFilter != null) {
        filter["PaymentStatus"] = _selectedStatusFilter;
      }

      final result = await _paymentProvider.get(filter: filter);
      if (mounted) {
        setState(() {
          _payments = result.result;
          _totalCount = result.count ?? 0;
        });
      }
    } catch (e) {
      print("Error loading payments: $e");
      if (mounted) {
        _error = "Greška pri učitavanju uplata: ${e.toString()}";
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  int get _totalPages => _totalCount > 0 ? (_totalCount / _pageSize).ceil() : 1;

  Future<void> _deletePayment(int paymentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Potvrda brisanja"),
            content: const Text(
              "Da li ste sigurni da želite obrisati ovu uplatu? Ova akcija se ne može poništiti.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text("Odustani"),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text("Obriši"),
              ),
            ],
          ),
    );

    if (confirm == true && mounted) {
      try {
        await _paymentProvider.delete(paymentId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Uplata uspješno obrisana."),
              backgroundColor: Colors.green,
            ),
          );
          if (_payments.length == 1 && _currentPage > 1) {
            _currentPage--;
          }
          _loadPayments(showLoading: false);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Greška pri brisanju uplate: ${e.toString()}"),
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
                  flex: 2,
                  child: DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: "Filter po statusu",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 15,
                      ),
                    ),
                    value: _selectedStatusFilter,
                    isExpanded: true,
                    items:
                        _paymentStatusOptions.entries.map((entry) {
                          return DropdownMenuItem<int>(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                    onChanged: (int? newValue) {
                      setState(() {
                        _selectedStatusFilter = newValue;
                        _currentPage = 1;
                      });
                      _loadPayments();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    _currentPage = 1;
                    _loadPayments();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text("Osvježi"),
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
            else if (_payments.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    "Nema pronađenih uplata za odabrani status.",
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
                                  columnSpacing: 12,
                                  headingRowColor:
                                      MaterialStateColor.resolveWith(
                                        (states) => Theme.of(
                                          context,
                                        ).primaryColorLight.withOpacity(0.3),
                                      ),
                                  columns: const [
                                    DataColumn(
                                      label: Text(
                                        "ID UPLATE",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        "ID REZ.",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        "IZNOS",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        "STRIPE ID",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        "STATUS",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        "KREIRANO",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        "USPJELO",
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
                                  rows: _payments.map(_buildRow).toList(),
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
                                        _loadPayments();
                                      }
                                      : null,
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed:
                                  _currentPage > 1
                                      ? () {
                                        setState(() => _currentPage--);
                                        _loadPayments();
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
                                        _loadPayments();
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
                                        _loadPayments();
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

  DataRow _buildRow(Payment payment) {
    final DateFormat dateTimeFormatter = DateFormat('dd.MM.yyyy HH:mm');
    final created = dateTimeFormatter.format(payment.createdAt);
    final succeeded =
        payment.succeededAt != null
            ? dateTimeFormatter.format(payment.succeededAt!)
            : "-";

    return DataRow(
      cells: [
        DataCell(Text(payment.id.toString())),
        DataCell(Text(payment.bookingId.toString())),
        DataCell(
          Text(
            "${(payment.amount / 100.0).toStringAsFixed(2)} ${payment.currency.toUpperCase()}",
          ),
        ),

        DataCell(
          Tooltip(
            message: payment.stripePaymentIntentId,
            child: SizedBox(
              width: 120,
              child: Text(
                payment.stripePaymentIntentId,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        DataCell(_buildStatusBadge(payment.status)),
        DataCell(Text(created)),
        DataCell(Text(succeeded)),
        DataCell(
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            tooltip: "Obriši uplatu (Oprez!)",
            onPressed: () => _deletePayment(payment.id),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(PaymentStatus status) {
    Color badgeColor;
    String statusText;

    switch (status) {
      case PaymentStatus.succeeded:
        badgeColor = Colors.green;
        statusText = "Uspjelo";
        break;
      case PaymentStatus.pending:
        badgeColor = Colors.orange;
        statusText = "Na čekanju";
        break;
      case PaymentStatus.failed:
        badgeColor = Colors.red;
        statusText = "Neuspjelo";
        break;
      case PaymentStatus.refunded:
        badgeColor = Colors.blueGrey;
        statusText = "Vraćeno";
        break;
      case PaymentStatus.unknown:
      default:
        badgeColor = Colors.grey;
        statusText = "Nepoznat";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: badgeColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
