import 'package:ecinema_mobile/screens/seat_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/showtime.dart';
import '../models/ticket_type.dart';
import '../providers/ticket_type_provider.dart';
import '../providers/booking_state.dart';

class TicketSelectionScreen extends StatefulWidget {
  final Showtime showtime;

  const TicketSelectionScreen({Key? key, required this.showtime})
    : super(key: key);

  @override
  State<TicketSelectionScreen> createState() => _TicketSelectionScreenState();
}

class _TicketSelectionScreenState extends State<TicketSelectionScreen> {
  late Future<List<TicketType>> _ticketTypesFuture;

  @override
  void initState() {
    super.initState();
    final bookingState = Provider.of<BookingState>(context, listen: false);
    bookingState.setShowtime(widget.showtime.id);
    bookingState.clearTickets();
    _ticketTypesFuture = TicketTypeProvider().get();
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = Provider.of<BookingState>(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Odaberite karte")),
      body: FutureBuilder<List<TicketType>>(
        future: _ticketTypesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text("Greška pri učitavanju tipova karata."),
            );
          }

          final types = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16),
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
                  "${widget.showtime.cinemaHall.name} • ${TimeOfDay.fromDateTime(widget.showtime.startTime).format(context)}",
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: types.length,
                    itemBuilder: (context, index) {
                      final type = types[index];
                      final qty = bookingState.countForTicketType(type.id);

                      return Card(
                        child: ListTile(
                          title: Text(type.name),
                          subtitle: Text(
                            "x ${type.priceModifier.toStringAsFixed(2)}",
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  bookingState.removeTicket(type.id);
                                },
                              ),
                              Text(
                                qty.toString(),
                                style: const TextStyle(fontSize: 16),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  final price =
                                      widget.showtime.basePrice *
                                      type.priceModifier;
                                  bookingState.addTicket(type.id, price);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Total: ${bookingState.totalPrice.toStringAsFixed(2)} KM",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed:
                      bookingState.tickets.isNotEmpty
                          ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => SeatSelectionScreen(
                                      showtime: widget.showtime,
                                    ),
                              ),
                            );
                          }
                          : null,
                  child: const Text("Dalje"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
