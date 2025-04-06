import 'package:flutter/material.dart';
import 'package:ecinema_desktop/models/cinema.dart';
import 'package:ecinema_desktop/providers/cinema_provider.dart';

class CinemaFormScreen extends StatefulWidget {
  final Cinema? cinema;

  const CinemaFormScreen({super.key, this.cinema});

  @override
  State<CinemaFormScreen> createState() => _CinemaFormScreenState();
}

class _CinemaFormScreenState extends State<CinemaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _provider = CinemaProvider();

  @override
  void initState() {
    super.initState();
    if (widget.cinema != null) {
      _nameController.text = widget.cinema!.name ?? "";
      _cityController.text = widget.cinema!.city ?? "";
      _addressController.text = widget.cinema!.address ?? "";
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveCinema() async {
    if (!_formKey.currentState!.validate()) return;

    final request = {
      "name": _nameController.text,
      "city": _cityController.text,
      "address": _addressController.text,
    };

    try {
      if (widget.cinema == null) {
        await _provider.insert(request);
      } else {
        await _provider.update(widget.cinema!.id!, request);
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Greška pri spremanju kina: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.cinema != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? "Uredi kino" : "Dodaj kino")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField("Naziv", _nameController),
              _buildTextField("Grad", _cityController),
              _buildTextField("Adresa", _addressController),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveCinema,
                child: Text(isEdit ? "Spremi promjene" : "Dodaj kino"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
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
