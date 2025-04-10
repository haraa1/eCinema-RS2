import 'package:flutter/material.dart';
import 'package:ecinema_desktop/models/seat_distribution_item.dart';
import 'package:ecinema_desktop/models/seat_type.dart';
import 'package:ecinema_desktop/providers/cinema_hall_provider.dart';
import 'package:ecinema_desktop/providers/seat_type_provider.dart';

class CinemaHallSeatsScreen extends StatefulWidget {
  final int cinemaHallId;

  const CinemaHallSeatsScreen({super.key, required this.cinemaHallId});

  @override
  State<CinemaHallSeatsScreen> createState() => _CinemaHallSeatsScreenState();
}

class _CinemaHallSeatsScreenState extends State<CinemaHallSeatsScreen> {
  final CinemaHallProvider _hallProvider = CinemaHallProvider();
  final SeatTypeProvider _seatTypeProvider = SeatTypeProvider();

  List<SeatType> _seatTypes = [];
  Map<int, TextEditingController> _controllers = {};
  int _totalCapacity = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _loading = true);
    final distribution = await _hallProvider.getSeatDistribution(
      widget.cinemaHallId,
    );
    final seatTypes = (await _seatTypeProvider.get()).result;

    _seatTypes = seatTypes;

    for (final type in _seatTypes) {
      final existing = distribution.firstWhere(
        (d) => d.seatTypeId == type.id,
        orElse: () => SeatDistributionItem(seatTypeId: type.id!, count: 0),
      );
      _controllers[type.id!] = TextEditingController(
        text: existing.count.toString(),
      );
    }

    _totalCapacity = distribution.map((e) => e.count).fold(0, (a, b) => a + b);
    setState(() => _loading = false);
  }

  int get _calculatedTotal {
    return _controllers.values
        .map((c) => int.tryParse(c.text) ?? 0)
        .fold(0, (a, b) => a + b);
  }

  Future<void> _save() async {
    final updated =
        _seatTypes.map((type) {
          return SeatDistributionItem(
            seatTypeId: type.id!,
            count: int.tryParse(_controllers[type.id!]!.text) ?? 0,
          );
        }).toList();

    if (_calculatedTotal != _totalCapacity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Ukupan broj sjedišta mora biti jednak trenutnom kapacitetu.",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await _hallProvider.updateSeatDistribution(
        widget.cinemaHallId,
        _calculatedTotal,
        updated,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Raspored sjedišta je ažuriran.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Uredi raspored sjedišta")),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text("Unesite broj sjedišta po tipu."),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView(
                        children:
                            _seatTypes.map((type) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(child: Text("${type.name}")),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _controllers[type.id],
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text("Ukupno: $_calculatedTotal / $_totalCapacity"),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save),
                      label: const Text("Spremi raspored"),
                    ),
                  ],
                ),
              ),
    );
  }
}
