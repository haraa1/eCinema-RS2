import 'package:flutter/material.dart';
import 'package:ecinema_desktop/models/concession.dart';
import 'package:ecinema_desktop/providers/concession_provider.dart';

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
  final _descController = TextEditingController();
  final _provider = ConcessionProvider();

  @override
  void initState() {
    super.initState();
    if (widget.concession != null) {
      _nameController.text = widget.concession!.name ?? "";
      _priceController.text = widget.concession!.price?.toString() ?? "";
      _descController.text = widget.concession!.description ?? "";
    }
  }

  Future<void> _saveConcession() async {
    if (!_formKey.currentState!.validate()) return;

    final request = {
      "name": _nameController.text,
      "price": double.tryParse(_priceController.text),
      "description": _descController.text,
    };

    try {
      if (widget.concession == null) {
        await _provider.insert(request);
      } else {
        await _provider.update(widget.concession!.id!, request);
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Greška pri spremanju proizvoda: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.concession != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? "Uredi proizvod" : "Dodaj proizvod")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildField("Naziv", _nameController),
              _buildField("Cijena", _priceController, isNumber: true),
              _buildField("Opis", _descController),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveConcession,
                child: Text(isEdit ? "Spremi promjene" : "Dodaj proizvod"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType:
            isNumber
                ? TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
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
}
