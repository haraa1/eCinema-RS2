import 'package:flutter/material.dart';
import 'package:ecinema_desktop/models/actor.dart';
import 'package:ecinema_desktop/providers/actor_provider.dart';

class ActorFormScreen extends StatefulWidget {
  final Actor? actor;

  const ActorFormScreen({super.key, this.actor});

  @override
  State<ActorFormScreen> createState() => _ActorFormScreenState();
}

class _ActorFormScreenState extends State<ActorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _provider = ActorProvider();

  @override
  void initState() {
    super.initState();
    if (widget.actor != null) {
      _firstNameController.text = widget.actor!.firstName ?? "";
      _lastNameController.text = widget.actor!.lastName ?? "";
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _saveActor() async {
    if (!_formKey.currentState!.validate()) return;

    final request = {
      "firstName": _firstNameController.text,
      "lastName": _lastNameController.text,
    };

    try {
      if (widget.actor == null) {
        await _provider.insert(request);
      } else {
        await _provider.update(widget.actor!.id!, request);
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Greška pri spremanju glumca: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.actor != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? "Uredi glumca" : "Dodaj glumca")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField("Ime", _firstNameController),
              _buildTextField("Prezime", _lastNameController),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveActor,
                child: Text(isEdit ? "Spremi promjene" : "Dodaj glumca"),
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
