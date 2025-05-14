import 'package:ecinema_mobile/models/payment.dart';
import 'package:ecinema_mobile/screens/booking_success.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:ecinema_mobile/models/concession.dart';
import 'package:ecinema_mobile/models/booking.dart';
import 'package:ecinema_mobile/providers/concession_provider.dart';
import 'package:ecinema_mobile/providers/booking_state.dart';
import 'package:ecinema_mobile/providers/booking_provider.dart';
import 'package:ecinema_mobile/providers/payment_provider.dart';

class ConcessionSelectionScreen extends StatefulWidget {
  const ConcessionSelectionScreen({Key? key}) : super(key: key);

  @override
  _ConcessionSelectionScreenState createState() =>
      _ConcessionSelectionScreenState();
}

class _ConcessionSelectionScreenState extends State<ConcessionSelectionScreen> {
  final Map<int, int> _selectedQuantities = {};
  bool _loading = false;

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
          }
          if (snapshot.hasError || !snapshot.hasData) {
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
                  onPressed:
                      _loading
                          ? null
                          : () async {
                            setState(() => _loading = true);

                            bookingState.selectedConcessions.clear();
                            bookingState.selectedConcessions.addAll(
                              _selectedQuantities,
                            );

                            try {
                              final Booking? booking = await BookingProvider()
                                  .insert({
                                    "showtimeId": bookingState.showtimeId!,
                                    "bookingTime":
                                        DateTime.now().toIso8601String(),
                                    "discountCode": "",
                                    "bookingConcessions":
                                        bookingState.selectedConcessions.entries
                                            .map(
                                              (e) => {
                                                "concessionId": e.key,
                                                "quantity": e.value,
                                              },
                                            )
                                            .toList(),
                                    "tickets":
                                        bookingState.tickets
                                            .map(
                                              (t) => {
                                                "seatId": t.seatId,
                                                "ticketTypeId": t.ticketTypeId,
                                                "price": t.price,
                                              },
                                            )
                                            .toList(),
                                  });
                              if (booking?.id == null) {
                                throw Exception("Booking creation failed.");
                              }
                              if (booking == null) {
                                throw StateError(
                                  'No booking available to pay for.',
                                );
                              }
                              final Payment intent = await PaymentProvider()
                                  .createIntent(booking.id!);

                              await Stripe.instance.initPaymentSheet(
                                paymentSheetParameters:
                                    SetupPaymentSheetParameters(
                                      paymentIntentClientSecret:
                                          intent.clientSecret,
                                      merchantDisplayName: 'eCinema',
                                    ),
                              );

                              await Stripe.instance.presentPaymentSheet();

                              if (!mounted) return;
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder:
                                      (_) => BookingSuccessScreen(
                                        booking: booking,
                                      ),
                                ),
                              );
                            } catch (e) {
                              final message =
                                  (e is StripeException)
                                      ? e.error.localizedMessage
                                      : e.toString();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Payment failed: $message'),
                                ),
                              );
                            } finally {
                              setState(() => _loading = false);
                            }
                          },
                  child:
                      _loading
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Text("Potvrdi i plati"),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
