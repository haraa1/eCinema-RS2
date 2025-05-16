import 'package:flutter/material.dart';
import 'package:ecinema_desktop/models/genre.dart';
import 'package:ecinema_desktop/providers/genre_provider.dart';

class GenreFormScreen extends StatefulWidget {
  final Genre? genre;
  const GenreFormScreen({super.key, this.genre});

  @override
  _GenreFormScreenState createState() => _GenreFormScreenState();
}

class _GenreFormScreenState extends State<GenreFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final GenreProvider _genreProvider = GenreProvider();

  bool get isEditMode => widget.genre != null;

  @override
  void initState() {
    super.initState();
    if (widget.genre != null) {
      _nameController.text = widget.genre!.name ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveGenre() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final request = {"name": _nameController.text.trim()};

    try {
      String successMessage;
      if (isEditMode) {
        await _genreProvider.update(widget.genre!.id!, request);
        successMessage = "Žanr uspješno ažuriran.";
      } else {
        await _genreProvider.insert(request);
        successMessage = "Žanr uspješno dodan.";
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
            content: Text("Greška pri spremanju žanra: ${e.toString()}"),
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
        title: Text(isEditMode ? "Uredi žanr" : "Dodaj novi žanr"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                label: "Naziv žanra",
                controller: _nameController,
                requiredErrorMsg: "Unesite naziv žanra.",
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveGenre,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(isEditMode ? "Spremi promjene" : "Spremi žanr"),
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
