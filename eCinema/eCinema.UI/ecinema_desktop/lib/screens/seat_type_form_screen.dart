import 'package:flutter/material.dart';
import 'package:ecinema_desktop/models/seat_type.dart';
import 'package:ecinema_desktop/providers/seat_type_provider.dart';
import 'package:flutter/services.dart';

class SeatTypeFormScreen extends StatefulWidget {
  final SeatType? seatType;
  const SeatTypeFormScreen({super.key, this.seatType});

  @override
  State<SeatTypeFormScreen> createState() => _SeatTypeFormScreenState();
}

class _SeatTypeFormScreenState extends State<SeatTypeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceMultiplierController = TextEditingController();
  final _seatTypeProvider = SeatTypeProvider();

  bool get isEditMode => widget.seatType != null;

  @override
  void initState() {
    super.initState();
    if (widget.seatType != null) {
      _nameController.text = widget.seatType!.name ?? '';
      _priceMultiplierController.text =
          widget.seatType!.priceMultiplier?.toStringAsFixed(2) ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceMultiplierController.dispose();
    super.dispose();
  }

  Future<void> _saveSeatType() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    double? priceMultiplier = double.tryParse(
      _priceMultiplierController.text.trim().replaceAll(',', '.'),
    );
    if (priceMultiplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Multiplikator cijene nije u ispravnom formatu."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final request = {
      'name': _nameController.text.trim(),
      'priceMultiplier': priceMultiplier,
    };

    try {
      String successMessage;
      if (!isEditMode) {
        await _seatTypeProvider.insert(request);
        successMessage = "Vrsta sjedala uspješno dodana.";
      } else {
        await _seatTypeProvider.update(widget.seatType!.id!, request);
        successMessage = "Podaci o vrsti sjedala uspješno ažurirani.";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.green,
          ),
        );

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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditMode ? 'Uredi vrstu sjedala' : 'Dodaj novu vrstu sjedala',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                label: 'Naziv vrste sjedala',
                controller: _nameController,
                requiredErrorMsg: "Unesite naziv vrste sjedala.",
              ),
              _buildTextField(
                label: 'Multiplikator cijene (npr. 1.0, 1.2, 0.8)',
                controller: _priceMultiplierController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^\d*([.,])?\d{0,2}'),
                  ),
                ],
                requiredErrorMsg: "Unesite multiplikator cijene.",
                customValidator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final val = value.replaceAll(',', '.');
                  final multiplier = double.tryParse(val);
                  if (multiplier == null) {
                    return 'Unesite validan broj za multiplikator.';
                  }
                  if (multiplier < 0) {
                    return 'Multiplikator ne može biti negativan.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveSeatType,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  isEditMode ? 'Spremi promjene' : 'Dodaj vrstu sjedala',
                ),
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
    List<TextInputFormatter>? inputFormatters,
    String? requiredErrorMsg,
    String? Function(String?)? customValidator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
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
}
