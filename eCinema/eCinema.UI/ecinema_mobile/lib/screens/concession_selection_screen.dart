import 'package:ecinema_mobile/providers/booking_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/concession.dart';
import '../providers/concession_provider.dart';
import '../services/booking_service.dart';

class ConcessionScreen extends StatefulWidget {
  @override
  _ConcessionScreenState createState() => _ConcessionScreenState();
}

class _ConcessionScreenState extends State<ConcessionScreen> {
  final Map<int, int> _selectedQuantities = {};

  @override
  Widget build(BuildContext context) {
    final bookingState = Provider.of<BookingState>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text("Odaberite hranu i piće")),
      body: FutureBuilder<List<Concession>>(
        future: ConcessionProvider().get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Failed to load concessions."));
          }

          final concessions = snapshot.data!;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Izabrali ste ${bookingState.tickets.length} karte",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: concessions.length,
                  itemBuilder: (context, index) {
                    final item = concessions[index];
                    final qty = _selectedQuantities[item.id!] ?? 0;

                    return ListTile(
                      title: Text(
                        "${item.name} - ${item.price?.toStringAsFixed(2)} KM",
                      ),
                      subtitle: Text(item.description ?? ""),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed:
                                qty > 0
                                    ? () {
                                      setState(() {
                                        _selectedQuantities[item.id!] = qty - 1;
                                      });
                                    }
                                    : null,
                          ),
                          Text(qty.toString()),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                _selectedQuantities[item.id!] = qty + 1;
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    bookingState.selectedConcessions.clear();
                    bookingState.selectedConcessions.addAll(
                      _selectedQuantities,
                    );

                    await submitBooking(bookingState);

                    if (!mounted) return;
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text("Potvrdi"),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
