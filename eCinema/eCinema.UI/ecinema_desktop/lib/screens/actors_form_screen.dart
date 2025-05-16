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
  final _actorProvider = ActorProvider();

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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final request = {
      "firstName": _firstNameController.text.trim(),
      "lastName": _lastNameController.text.trim(),
    };

    try {
      if (widget.actor == null) {
        await _actorProvider.insert(request);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Glumac uspješno dodan."),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await _actorProvider.update(widget.actor!.id!, request);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Podaci o glumcu uspješno ažurirani."),
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
              "Greška pri spremanju glumca: ${e.toString()}. Pokušajte ponovo.",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.actor != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? "Uredi glumca" : "Dodaj novog glumca"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                controller: _firstNameController,
                label: "Ime",
                requiredErrorMsg: "Unesite ime glumca.",
              ),
              _buildTextField(
                controller: _lastNameController,
                label: "Prezime",
                requiredErrorMsg: "Unesite prezime glumca.",
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveActor,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(isEditMode ? "Spremi promjene" : "Dodaj glumca"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? requiredErrorMsg,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (requiredErrorMsg != null &&
              (value == null || value.trim().isEmpty)) {
            return requiredErrorMsg;
          }
          return null;
        },
      ),
    );
  }
}
