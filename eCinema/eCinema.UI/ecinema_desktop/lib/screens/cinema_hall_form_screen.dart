import 'package:ecinema_desktop/models/seat_distribution_item.dart';
import 'package:flutter/material.dart';
import 'package:ecinema_desktop/models/cinema_hall.dart';
import 'package:ecinema_desktop/providers/cinema_hall_provider.dart';
import 'package:ecinema_desktop/providers/cinema_provider.dart';
import 'package:ecinema_desktop/models/cinema.dart';

class CinemaHallFormScreen extends StatefulWidget {
  final CinemaHall? cinemaHall;

  const CinemaHallFormScreen({super.key, this.cinemaHall});

  @override
  State<CinemaHallFormScreen> createState() => _CinemaHallFormScreenState();
}

class _CinemaHallFormScreenState extends State<CinemaHallFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _capacityController = TextEditingController();

  final _cinemaHallProvider = CinemaHallProvider();
  final _cinemaProvider = CinemaProvider();

  List<Cinema> _cinemas = [];
  int? _selectedCinemaId;

  @override
  void initState() {
    super.initState();
    _loadCinemas();

    if (widget.cinemaHall != null) {
      _nameController.text = widget.cinemaHall!.name ?? '';
      _capacityController.text = widget.cinemaHall!.capacity?.toString() ?? '';
      _selectedCinemaId = widget.cinemaHall!.cinemaId;
    }
  }

  Future<void> _loadCinemas() async {
    final result = await _cinemaProvider.get();
    setState(() => _cinemas = result.result);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final request = {
      "name": _nameController.text,
      "capacity": int.parse(_capacityController.text),
      "cinemaId": _selectedCinemaId,
    };

    try {
      if (widget.cinemaHall == null) {
        final newHall = await _cinemaHallProvider.insert(request);

        await _cinemaHallProvider.addSeats(newHall.id!, 50, 1);

        await _cinemaHallProvider.updateSeatDistribution(newHall.id!, 50, [
          SeatDistributionItem(seatTypeId: 1, count: 40),
          SeatDistributionItem(seatTypeId: 2, count: 5),
          SeatDistributionItem(seatTypeId: 3, count: 5),
        ]);
      } else {
        await _cinemaHallProvider.update(widget.cinemaHall!.id!, request);
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.cinemaHall != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? "Uredi dvoranu" : "Dodaj dvoranu")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField("Naziv", _nameController),
              _buildTextField(
                "Kapacitet",
                _capacityController,
                isNumeric: true,
              ),
              _buildCinemaDropdown(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _save,
                child: Text(isEdit ? "Spremi promjene" : "Dodaj dvoranu"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumeric = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator:
            (value) =>
                (value == null || value.isEmpty) ? 'Obavezno polje' : null,
      ),
    );
  }

  Widget _buildCinemaDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<int>(
        value: _selectedCinemaId,
        decoration: const InputDecoration(
          labelText: "Kino",
          border: OutlineInputBorder(),
        ),
        items:
            _cinemas
                .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name!)))
                .toList(),
        onChanged: (value) => setState(() => _selectedCinemaId = value),
        validator: (value) => value == null ? 'Odaberite kino' : null,
      ),
    );
  }
}
