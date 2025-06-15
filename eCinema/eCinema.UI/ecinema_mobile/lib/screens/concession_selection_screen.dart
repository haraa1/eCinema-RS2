import 'package:ecinema_mobile/models/payment.dart';
import 'package:ecinema_mobile/models/payment_intent_response.dart';
import 'package:ecinema_mobile/screens/booking_success.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecinema_mobile/models/concession.dart';
import 'package:ecinema_mobile/models/booking.dart';
import 'package:ecinema_mobile/providers/concession_provider.dart';
import 'package:ecinema_mobile/providers/booking_state.dart';
import 'package:ecinema_mobile/providers/booking_provider.dart';
import 'package:ecinema_mobile/providers/payment_provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;

class ConcessionSelectionScreen extends StatefulWidget {
  const ConcessionSelectionScreen({Key? key}) : super(key: key);

  @override
  _ConcessionSelectionScreenState createState() =>
      _ConcessionSelectionScreenState();
}

class _ConcessionSelectionScreenState extends State<ConcessionSelectionScreen> {
  final Map<int, int> _selectedQuantities = {};
  final TextEditingController _discountCodeController = TextEditingController();
  bool _loading = false;
  String? _discountErrorText;

  @override
  void dispose() {
    _discountCodeController.dispose();
    super.dispose();
  }

  Future<void> _processBookingAndPayment() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _discountErrorText = null;
    });

    final bookingState = Provider.of<BookingState>(context, listen: false);
    final bookingProvider = Provider.of<BookingProvider>(
      context,
      listen: false,
    );
    final paymentProvider = Provider.of<PaymentProvider>(
      context,
      listen: false,
    );

    bookingState.selectedConcessions.clear();
    _selectedQuantities.forEach((key, value) {
      if (value > 0) {
        bookingState.selectedConcessions[key] = value;
      }
    });

    final bookingPayload = {
      "showtimeId": bookingState.showtimeId!,
      "discountCode":
          _discountCodeController.text.trim().isEmpty
              ? null
              : _discountCodeController.text.trim(),
      "bookingConcessions":
          bookingState.selectedConcessions.entries
              .map((e) => {"concessionId": e.key, "quantity": e.value})
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
    };
    try {
      print("CONCESSION_DEBUG: Calling bookingProvider.create...");
      final Booking? booking = await bookingProvider.create(bookingPayload);
      print(
        "CONCESSION_DEBUG: bookingProvider.create returned. Booking: ${booking?.id}",
      );

      if (booking == null || booking.id == null) {
        print(
          "CONCESSION_DEBUG: Booking creation failed or booking ID is null.",
        );
        throw Exception(
          "Kreiranje rezervacije nije uspjelo. Molimo pokušajte ponovo.",
        );
      }
      final PaymentIntentResponse paymentIntentResponse = await paymentProvider
          .createIntent(booking.id!);

      if (paymentIntentResponse.clientSecret == null &&
          paymentIntentResponse.paymentData.status == PaymentStatus.succeeded) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Rezervacija uspješna (popust primjenjen)!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => BookingSuccessScreen(booking: booking),
          ),
          (Route<dynamic> route) => false,
        );
      } else if (paymentIntentResponse.clientSecret != null) {
        print(
          "CONCESSION_DEBUG: Client secret received. Initializing payment sheet.",
        );
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntentResponse.clientSecret!,
            merchantDisplayName: 'eCinema',
          ),
        );

        await Stripe.instance.presentPaymentSheet();

        if (!mounted) return;

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => BookingSuccessScreen(booking: booking),
          ),
          (Route<dynamic> route) => false,
        );
      } else {
        print(
          "CONCESSION_DEBUG: Error in payment preparation. ClientSecret is null and status is not succeeded. Status: ${paymentIntentResponse.paymentData.status}",
        );
        throw Exception(
          "Došlo je do greške pri pripremi plaćanja. Status: ${paymentIntentResponse.paymentData.status.toString().split('.').last}",
        );
      }
    } catch (e, s) {
      if (!mounted) return;
      String errorMessage = "Došlo je do greške.";
      if (e is StripeException) {
        errorMessage = e.error.localizedMessage ?? "Greška pri plaćanju.";
        print(
          "CONCESSION_DEBUG: StripeException: Code: ${e.error.code}, Message: ${e.error.message}, Localized: ${e.error.localizedMessage}",
        );
      } else if (e is Exception) {
        final eStr = e.toString().toLowerCase();
        if (eStr.contains("invalid or expired discount code") ||
            eStr.contains("neispravan ili istekao kod")) {
          errorMessage = "Uneseni kod za popust je neispravan ili je istekao.";
          setState(() {
            _discountErrorText = errorMessage;
          });
        } else {
          errorMessage = e.toString().replaceFirst("Exception: ", "");
        }
      }
      if (!(_discountErrorText != null && errorMessage == _discountErrorText)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      } else {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = Provider.of<BookingState>(context, listen: false);

    final concessionProvider = Provider.of<ConcessionProvider>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Odaberite hranu i piće")),
      body: FutureBuilder<List<Concession>>(
        future: concessionProvider.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text("Greška pri učitavanju proizvoda: ${snapshot.error}"),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Nema dostupnih proizvoda."));
          }

          final concessions = snapshot.data!;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Izabrali ste ${bookingState.tickets.length} ${bookingState.tickets.length == 1 ? 'kartu' : 'karata'}",
                  style: const TextStyle(
                    fontSize: 18,
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

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        title: Text(
                          item.name ?? "Nepoznat proizvod",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item.description != null &&
                                item.description!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(item.description!),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                "${item.price?.toStringAsFixed(2) ?? 'N/A'} KM",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              color:
                                  qty > 0
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey,
                              onPressed:
                                  qty > 0
                                      ? () {
                                        setState(() {
                                          _selectedQuantities[item.id!] =
                                              qty - 1;
                                        });
                                      }
                                      : null,
                            ),
                            Text(
                              qty.toString(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              color: Theme.of(context).colorScheme.primary,
                              onPressed: () {
                                setState(() {
                                  _selectedQuantities[item.id!] = qty + 1;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: TextField(
                  controller: _discountCodeController,
                  decoration: InputDecoration(
                    labelText: "Unesite kod za popust (opcionalno)",
                    hintText: "Npr. POPUST20",
                    border: const OutlineInputBorder(),
                    errorText: _discountErrorText,
                    suffixIcon:
                        _discountCodeController.text.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _discountCodeController.clear();
                                setState(() {
                                  _discountErrorText = null;
                                });
                              },
                            )
                            : null,
                  ),
                  onChanged: (text) {
                    if (_discountErrorText != null) {
                      setState(() {
                        _discountErrorText = null;
                      });
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  onPressed: _loading ? null : _processBookingAndPayment,
                  child:
                      _loading
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
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
