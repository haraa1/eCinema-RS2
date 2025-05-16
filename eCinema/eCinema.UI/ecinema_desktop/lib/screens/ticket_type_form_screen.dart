import 'package:flutter/material.dart';
import 'package:ecinema_desktop/models/ticket_type.dart';
import 'package:ecinema_desktop/providers/ticket_type_provider.dart';
import 'package:flutter/services.dart';

class TicketTypeFormScreen extends StatefulWidget {
  final TicketType? ticketType;
  const TicketTypeFormScreen({Key? key, this.ticketType}) : super(key: key);

  @override
  State<TicketTypeFormScreen> createState() => _TicketTypeFormScreenState();
}

class _TicketTypeFormScreenState extends State<TicketTypeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceModifierController = TextEditingController();
  final _ticketTypeProvider = TicketTypeProvider();

  bool get isEditMode => widget.ticketType != null;

  @override
  void initState() {
    super.initState();
    if (widget.ticketType != null) {
      _nameController.text = widget.ticketType!.name ?? '';

      _priceModifierController.text =
          widget.ticketType!.priceModifier?.toStringAsFixed(2) ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceModifierController.dispose();
    super.dispose();
  }

  Future<void> _saveTicketType() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    double? priceModifier = double.tryParse(
      _priceModifierController.text.trim().replaceAll(',', '.'),
    );
    if (priceModifier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Modifikator cijene nije u ispravnom formatu."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final request = {
      'name': _nameController.text.trim(),
      'priceModifier': priceModifier,
    };

    try {
      String successMessage;
      if (!isEditMode) {
        await _ticketTypeProvider.insert(request);
        successMessage = "Tip karte uspješno dodan.";
      } else {
        await _ticketTypeProvider.update(widget.ticketType!.id!, request);
        successMessage = "Podaci o tipu karte uspješno ažurirani.";
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
        title: Text(isEditMode ? 'Uredi tip karte' : 'Dodaj novi tip karte'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                label: 'Naziv tipa karte (npr. Studentska, Penzionerska, VIP)',
                controller: _nameController,
                requiredErrorMsg: "Unesite naziv tipa karte.",
              ),
              _buildTextField(
                label:
                    'Modifikator cijene (npr. 1.0 za osnovnu, 0.8 za popust, 1.5 za premium)',
                controller: _priceModifierController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^\d*([.,])?\d{0,2}'),
                  ),
                ],
                requiredErrorMsg: "Unesite modifikator cijene.",
                customValidator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final val = value.replaceAll(',', '.');
                  final modifier = double.tryParse(val);
                  if (modifier == null) {
                    return 'Unesite validan broj za modifikator.';
                  }
                  if (modifier < 0) {
                    return 'Modifikator ne može biti negativan.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveTicketType,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(isEditMode ? 'Spremi promjene' : 'Dodaj tip karte'),
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
          helperText:
              (label.contains("Modifikator"))
                  ? "Npr. 1.0 = ista cijena, 0.8 = 20% popusta, 1.2 = 20% skuplje"
                  : null,
          helperMaxLines: 2,
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
