import 'package:flutter/foundation.dart';

class TempTicket {
  final int ticketTypeId;
  final double price;
  int? seatId;

  TempTicket({required this.ticketTypeId, required this.price, this.seatId});
}

class BookingState extends ChangeNotifier {
  int? showtimeId;
  final List<TempTicket> _tickets = [];
  late final Map<int, int> selectedConcessions = {};

  List<TempTicket> get tickets => List.unmodifiable(_tickets);

  void setShowtime(int id) {
    showtimeId = id;
    notifyListeners();
  }

  void clearTickets() {
    _tickets.clear();
    selectedConcessions.clear();
    notifyListeners();
  }

  void addTicket(int ticketTypeId, double price) {
    _tickets.add(TempTicket(ticketTypeId: ticketTypeId, price: price));
    notifyListeners();
  }

  void removeTicket(int ticketTypeId) {
    final index = _tickets.lastIndexWhere(
      (t) => t.ticketTypeId == ticketTypeId && t.seatId == null,
    );
    if (index != -1) {
      _tickets.removeAt(index);
      notifyListeners();
    }
  }

  int countForTicketType(int ticketTypeId) {
    return _tickets.where((t) => t.ticketTypeId == ticketTypeId).length;
  }

  double get totalPrice => _tickets.fold(0.0, (sum, t) => sum + t.price);

  void updateConcession(int concessionId, int quantity) {
    if (quantity <= 0) {
      selectedConcessions.remove(concessionId);
    } else {
      selectedConcessions[concessionId] = quantity;
    }
    notifyListeners();
  }
}
