import 'package:flutter/material.dart';
import 'package:ecinema_desktop/models/concession.dart';
import 'package:ecinema_desktop/providers/concession_provider.dart';
import 'package:flutter/services.dart';

class ConcessionFormScreen extends StatefulWidget {
  final Concession? concession;

  const ConcessionFormScreen({super.key, this.concession});

  @override
  State<ConcessionFormScreen> createState() => _ConcessionFormScreenState();
}

class _ConcessionFormScreenState extends State<ConcessionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _concessionProvider = ConcessionProvider();

  @override
  void initState() {
    super.initState();
    if (widget.concession != null) {
      _nameController.text = widget.concession!.name ?? "";
      _priceController.text =
          widget.concession!.price?.toStringAsFixed(2) ?? "";
      _descriptionController.text = widget.concession!.description ?? "";
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveConcession() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    double? price = double.tryParse(
      _priceController.text.trim().replaceAll(',', '.'),
    );
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cijena nije u ispravnom formatu."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final request = {
      "name": _nameController.text.trim(),
      "price": price,
      "description": _descriptionController.text.trim(),
    };

    try {
      if (widget.concession == null) {
        await _concessionProvider.insert(request);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Proizvod uspješno dodan."),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await _concessionProvider.update(widget.concession!.id!, request);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Podaci o proizvodu uspješno ažurirani."),
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
            content: Text(
              "Greška pri spremanju proizvoda: ${e.toString()}. Pokušajte ponovo.",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.concession != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? "Uredi proizvod" : "Dodaj novi proizvod"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                label: "Naziv proizvoda",
                controller: _nameController,
                requiredErrorMsg: "Unesite naziv proizvoda.",
              ),
              _buildTextField(
                label: "Cijena (npr. 5.99)",
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^\d*([.,])?\d{0,2}'),
                  ),
                ],
                requiredErrorMsg: "Unesite cijenu.",
                customValidator: (value) {
                  if (value == null || value.isEmpty) return null;

                  final price = double.tryParse(value.replaceAll(',', '.'));
                  if (price == null) {
                    return 'Unesite validan broj za cijenu.';
                  }
                  if (price <= 0) {
                    return 'Cijena mora biti veća od 0.';
                  }
                  return null;
                },
              ),
              _buildTextField(
                label: "Opis proizvoda",
                controller: _descriptionController,
                maxLines: 3,
                requiredErrorMsg: "Unesite opis proizvoda.",
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveConcession,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(isEditMode ? "Spremi promjene" : "Dodaj proizvod"),
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
    int maxLines = 1,
    String? requiredErrorMsg,
    String? Function(String?)? customValidator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
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
