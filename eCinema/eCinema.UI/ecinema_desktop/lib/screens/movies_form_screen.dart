import 'package:ecinema_desktop/models/actor.dart';
import 'package:ecinema_desktop/models/genre.dart';
import 'package:ecinema_desktop/models/movie.dart';
import 'package:ecinema_desktop/providers/actor_provider.dart';
import 'package:ecinema_desktop/providers/genre_provider.dart';
import 'package:ecinema_desktop/providers/movie_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MovieFormScreen extends StatefulWidget {
  final Movie? movie;

  const MovieFormScreen({Key? key, this.movie}) : super(key: key);

  @override
  State<MovieFormScreen> createState() => _MovieFormScreenState();
}

class _MovieFormScreenState extends State<MovieFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _provider = MovieProvider();
  final _genreProvider = GenreProvider();
  final _actorProvider = ActorProvider();

  List<int> _selectedGenreIds = [];
  List<int> _selectedActorIds = [];

  List<Genre> _genres = [];
  List<Actor> _actors = [];

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  final _languageController = TextEditingController();
  DateTime? _releaseDate;
  int _status = 0;
  int _pgRating = 0;

  _loadDropdowns() async {
    var genreResult = await _genreProvider.get();
    var actorResult = await _actorProvider.get();

    setState(() {
      _genres = genreResult.result;
      _actors = actorResult.result;

      if (widget.movie != null) {
        _selectedGenreIds = widget.movie!.genreIds ?? [];
        _selectedActorIds = widget.movie!.actorIds ?? [];
      }
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.movie != null) {
      final m = widget.movie!;
      _titleController.text = m.title ?? "";
      _descriptionController.text = m.description ?? "";
      _durationController.text = m.durationMinutes?.toString() ?? "";
      _languageController.text = m.language ?? "";
      _releaseDate = m.releaseDate;
      _status = m.status ?? 0;
      _pgRating = m.pgRating ?? 0;
    }
    _loadDropdowns();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _languageController.dispose();
    super.dispose();
  }

  Future<void> _saveMovie() async {
    if (!_formKey.currentState!.validate()) return;

    final request = {
      "title": _titleController.text,
      "description": _descriptionController.text,
      "durationMinutes": int.tryParse(_durationController.text),
      "language": _languageController.text,
      "releaseDate": _releaseDate?.toIso8601String(),
      "status": _status,
      "pgRating": _pgRating,
      "genreIds": _selectedGenreIds,
      "actorIds": _selectedActorIds,
    };

    try {
      if (widget.movie == null) {
        await _provider.insert(request);
      } else {
        await _provider.update(widget.movie!.id!, request);
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving movie: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _releaseDate ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _releaseDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.movie != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? "Uredi film" : "Dodaj film")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField("Naslov", _titleController),
              _buildTextField("Opis", _descriptionController, maxLines: 3),
              _buildTextField(
                "Trajanje (min)",
                _durationController,
                keyboardType: TextInputType.number,
              ),
              _buildTextField("Jezik", _languageController),
              _buildDatePicker(),
              _buildDropdown(
                "Status",
                _status,
                (val) => setState(() => _status = val!),
                {0: "Aktivan", 1: "Uskoro"},
              ),
              _buildDropdown(
                "PG Ocjena",
                _pgRating,
                (val) => setState(() => _pgRating = val!),
                {0: "PG-13", 1: "R"},
              ),
              const SizedBox(height: 12),
              Text("Žanrovi", style: Theme.of(context).textTheme.titleMedium),
              Wrap(
                spacing: 8,
                children:
                    _genres.map((genre) {
                      final selected = _selectedGenreIds.contains(genre.id);
                      return FilterChip(
                        label: Text(genre.name ?? ""),
                        selected: selected,
                        onSelected: (val) {
                          setState(() {
                            if (genre.id == null) return;
                            val
                                ? _selectedGenreIds.add(genre.id!)
                                : _selectedGenreIds.remove(genre.id);
                          });
                        },
                      );
                    }).toList(),
              ),
              const SizedBox(height: 12),
              Text("Glumci", style: Theme.of(context).textTheme.titleMedium),
              Wrap(
                spacing: 8,
                children:
                    _actors.map((actor) {
                      final selected = _selectedActorIds.contains(actor.id);
                      return FilterChip(
                        label: Text(actor.firstName ?? ""),
                        selected: selected,
                        onSelected: (val) {
                          setState(() {
                            if (actor.id == null) return;
                            val
                                ? _selectedActorIds.add(actor.id!)
                                : _selectedActorIds.remove(actor.id);
                          });
                        },
                      );
                    }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveMovie,
                child: Text(isEdit ? "Spremi promjene" : "Dodaj film"),
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
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
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

  Widget _buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            _releaseDate != null
                ? DateFormat('yyyy-MM-dd').format(_releaseDate!)
                : "Odaberite datum izlaska",
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _pickDate,
            child: const Text("Odaberi datum"),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    int value,
    ValueChanged<int?> onChanged,
    Map<int, String> items,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<int>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items:
            items.entries
                .map(
                  (entry) => DropdownMenuItem<int>(
                    value: entry.key,
                    child: Text(entry.value),
                  ),
                )
                .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
