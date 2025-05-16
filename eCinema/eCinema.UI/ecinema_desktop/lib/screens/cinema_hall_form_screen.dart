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
  bool _isLoadingCinemas = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData().then((_) {
      if (widget.cinemaHall != null) {
        _nameController.text = widget.cinemaHall!.name ?? '';
        _capacityController.text =
            widget.cinemaHall!.capacity?.toString() ?? '';
        _selectedCinemaId = widget.cinemaHall!.cinemaId;
        if (mounted) setState(() {});
      }
    });
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoadingCinemas = true);
    try {
      final cinemaResult = await _cinemaProvider.get();

      if (mounted) {
        setState(() {
          _cinemas = cinemaResult.result;
          _isLoadingCinemas = false;
        });
      }
    } catch (e) {
      if (mounted) {
        print("Error loading initial data: $e");
        setState(() => _isLoadingCinemas = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Greška pri učitavanju podataka: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    int? capacity = int.tryParse(_capacityController.text.trim());
    if (capacity == null || capacity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kapacitet mora biti validan pozitivan broj."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final request = {
      "name": _nameController.text.trim(),
      "capacity": capacity,
      "cinemaId": _selectedCinemaId,
    };

    try {
      if (widget.cinemaHall == null) {
        final newHall = await _cinemaHallProvider.insert(request);

        if (newHall.id != null) {
          await _cinemaHallProvider.addSeats(newHall.id!, capacity, 1);

          List<SeatDistributionItem> distribution = [
            SeatDistributionItem(
              seatTypeId: 1,
              count: (capacity * 0.8).round(),
            ),
            SeatDistributionItem(
              seatTypeId: 2,
              count: (capacity * 0.1).round(),
            ),
            SeatDistributionItem(
              seatTypeId: 3,
              count:
                  capacity -
                  (capacity * 0.8).round() -
                  (capacity * 0.1).round(),
            ),
          ];

          await _cinemaHallProvider.updateSeatDistribution(
            newHall.id!,
            capacity,
            distribution,
          );
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Dvorana uspješno dodana."),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await _cinemaHallProvider.update(widget.cinemaHall!.id!, request);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Podaci o dvorani uspješno ažurirani."),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Greška pri spremanju: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.cinemaHall != null;

    if (_isLoadingCinemas && _cinemas.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isEditMode ? "Uredi dvoranu" : "Dodaj dvoranu"),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            semanticsLabel: "Učitavanje kina...",
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? "Uredi dvoranu" : "Dodaj dvoranu"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                label: "Naziv dvorane",
                controller: _nameController,
                requiredErrorMsg: "Unesite naziv dvorane.",
              ),
              _buildTextField(
                label: "Ukupan kapacitet sjedišta",
                controller: _capacityController,
                keyboardType: TextInputType.number,
                requiredErrorMsg: "Unesite kapacitet.",
                customValidator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final n = int.tryParse(value);
                  if (n == null) {
                    return 'Unesite validan broj.';
                  }
                  if (n <= 0) {
                    return 'Kapacitet mora biti veći od 0.';
                  }
                  return null;
                },
              ),
              _buildCinemaDropdown(),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoadingCinemas ? null : _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(isEditMode ? "Spremi promjene" : "Dodaj dvoranu"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? requiredErrorMsg,
    String? Function(String?)? customValidator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          final val = value?.trim() ?? '';
          if (requiredErrorMsg != null && val.isEmpty) {
            return requiredErrorMsg;
          }
          if (customValidator != null) {
            return customValidator(val);
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCinemaDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<int>(
        value:
            _cinemas.any((c) => c.id == _selectedCinemaId)
                ? _selectedCinemaId
                : null,
        decoration: const InputDecoration(
          labelText: "Kino",
          border: OutlineInputBorder(),
          hintText: "Odaberite kino",
        ),
        isExpanded: true,
        items:
            _cinemas.map((Cinema cinema) {
              return DropdownMenuItem<int>(
                value: cinema.id,
                child: Text(cinema.name ?? "Nepoznato kino"),
              );
            }).toList(),
        onChanged:
            _isLoadingCinemas
                ? null
                : (int? newValue) {
                  setState(() => _selectedCinemaId = newValue);
                },
        validator: (value) => value == null ? 'Molimo odaberite kino.' : null,
        disabledHint:
            _isLoadingCinemas ? const Text("Učitavanje kina...") : null,
        hint:
            _isLoadingCinemas && _cinemas.isEmpty
                ? const Text("Učitavanje kina...")
                : null,
      ),
    );
  }
}
