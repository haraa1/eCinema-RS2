import 'package:ecinema_mobile/screens/concession_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/showtime.dart';
import '../models/seat.dart';
import '../providers/cinema_hall_provider.dart';
import '../providers/booking_state.dart';

class SeatSelectionScreen extends StatefulWidget {
  final Showtime showtime;

  const SeatSelectionScreen({Key? key, required this.showtime})
    : super(key: key);

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  late Future<Map<String, List<Seat>>> _groupedSeatsFuture;
  final List<int> _selectedSeatIds = [];

  @override
  void initState() {
    super.initState();
    _groupedSeatsFuture = _loadGroupedSeats();
  }

  Future<Map<String, List<Seat>>> _loadGroupedSeats() async {
    final showtimeId = widget.showtime.id;

    final seats = await CinemaHallProvider().getSeatsByShowtime(showtimeId);

    final grouped = <String, List<Seat>>{};
    for (final seat in seats) {
      grouped.putIfAbsent(seat.row ?? 'Unknown', () => []).add(seat);
    }
    for (final row in grouped.keys) {
      grouped[row]!.sort((a, b) => (a.number ?? 0).compareTo(b.number ?? 0));
    }
    return grouped;
  }

  void _onSeatTap(Seat seat) {
    final bookingState = Provider.of<BookingState>(context, listen: false);
    final maxSelectable = bookingState.tickets.length;

    setState(() {
      if (_selectedSeatIds.contains(seat.id)) {
        _selectedSeatIds.remove(seat.id);
      } else if (_selectedSeatIds.length < maxSelectable &&
          seat.isAvailable == true) {
        if (seat.id != null) {
          _selectedSeatIds.add(seat.id!);
        }
      }
    });
  }

  void _assignSeatsAndProceed() {
    final bookingState = Provider.of<BookingState>(context, listen: false);
    for (int i = 0; i < bookingState.tickets.length; i++) {
      bookingState.tickets[i].seatId = _selectedSeatIds[i];
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ConcessionSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = Provider.of<BookingState>(context);
    final requiredSeats = bookingState.tickets.length;

    return Scaffold(
      appBar: AppBar(title: const Text("Odabir sjedišta")),
      body: FutureBuilder<Map<String, List<Seat>>>(
        future: _groupedSeatsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Greška pri učitavanju sjedišta"));
          }

          final groupedSeats = snapshot.data!;
          final selectedSeats = _selectedSeatIds
              .map((id) {
                final seat = groupedSeats.values
                    .expand((s) => s)
                    .firstWhere((s) => s.id == id);
                return "${seat.row}${seat.number}";
              })
              .join(", ");

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.showtime.movie.title ?? "Naslov",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${widget.showtime.cinemaHall.name} • Broj karata: $requiredSeats",
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text("PLATNO", style: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children:
                          groupedSeats.entries.map((entry) {
                            final rowLabel = entry.key;
                            final seats = entry.value;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Text(
                                    rowLabel,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children:
                                            seats.map((seat) {
                                              final isSelected =
                                                  _selectedSeatIds.contains(
                                                    seat.id,
                                                  );
                                              final isUnavailable =
                                                  seat.isAvailable == null ||
                                                  !seat.isAvailable!;

                                              Color color;
                                              if (isUnavailable) {
                                                color = Colors.grey[400]!;
                                              } else if (isSelected) {
                                                color = Colors.blue;
                                              } else {
                                                color = Colors.white;
                                              }

                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 4,
                                                    ),
                                                child: GestureDetector(
                                                  onTap: () => _onSeatTap(seat),
                                                  child: Container(
                                                    width: 32,
                                                    height: 32,
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                      color: color,
                                                      border: Border.all(
                                                        color: Colors.black26,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      seat.number.toString(),
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color:
                                                            isUnavailable
                                                                ? Colors.black26
                                                                : Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    LegendBox(color: Colors.white, label: "Dostupno"),
                    SizedBox(width: 10),
                    LegendBox(color: Colors.blue, label: "Odabrano"),
                    SizedBox(width: 10),
                    LegendBox(color: Colors.grey, label: "Zauzeto"),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "Odabrana mjesta: $selectedSeats",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed:
                      _selectedSeatIds.length == requiredSeats
                          ? _assignSeatsAndProceed
                          : null,
                  child: const Text("Potvrdi selekciju"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class LegendBox extends StatelessWidget {
  final Color color;
  final String label;

  const LegendBox({required this.color, required this.label, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          color: color,
          margin: const EdgeInsets.only(right: 6),
        ),
        Text(label),
      ],
    );
  }
}
