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
  final _movieProvider = MovieProvider();
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

  bool _isLoadingDropdowns = true;

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

  Future<void> _loadDropdowns() async {
    setState(() {
      _isLoadingDropdowns = true;
    });
    try {
      var genreResult = await _genreProvider.get();
      var actorResult = await _actorProvider.get();

      if (mounted) {
        setState(() {
          _genres = genreResult.result;
          _actors = actorResult.result;

          if (widget.movie != null) {
            _selectedGenreIds = widget.movie!.genreIds?.toList() ?? [];
            _selectedActorIds = widget.movie!.actorIds?.toList() ?? [];
          }
          _isLoadingDropdowns = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingDropdowns = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Greška pri učitavanju podataka: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

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
        await _movieProvider.insert(request);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Film uspješno dodan."),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await _movieProvider.update(widget.movie!.id!, request);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Promjene uspješno spremljene."),
            backgroundColor: Colors.green,
          ),
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Greška prilikom spremanja filma: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.movie != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? "Uredi film" : "Dodaj novi film"),
      ),
      body:
          _isLoadingDropdowns
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      _buildTextField(
                        controller: _titleController,
                        label: "Naslov",
                        requiredErrorMsg: "Unesite naslov filma.",
                      ),
                      _buildTextField(
                        controller: _descriptionController,
                        label: "Opis",
                        maxLines: 3,
                        requiredErrorMsg: "Unesite opis filma.",
                      ),
                      _buildTextField(
                        controller: _durationController,
                        label: "Trajanje (min)",
                        keyboardType: TextInputType.number,
                        requiredErrorMsg: "Unesite trajanje filma.",
                        customValidator: (value) {
                          if (value == null || value.isEmpty) return null;
                          final duration = int.tryParse(value);
                          if (duration == null) {
                            return 'Unesite validan broj za trajanje.';
                          }
                          if (duration <= 0) {
                            return 'Trajanje mora biti veće od 0.';
                          }
                          return null;
                        },
                      ),
                      _buildTextField(
                        controller: _languageController,
                        label: "Jezik",

                        requiredErrorMsg: "Unesite jezik filma.",
                      ),
                      _buildDatePickerField(),

                      _buildDropdown(
                        label: "Status",
                        currentValue: _status,
                        items: const {
                          0: "Aktivan",
                          1: "Uskoro",
                          2: "Neaktivan",
                        },
                        onChanged: (val) => setState(() => _status = val!),
                        requiredErrorMsg: "Odaberite status.",
                      ),
                      _buildDropdown(
                        label: "PG Ocjena",
                        currentValue: _pgRating,
                        items: const {
                          0: "G (General Audiences)",
                          1: "PG (Parental Guidance Suggested)",
                          2: "PG-13",
                          3: "R (Restricted)",
                        },
                        onChanged: (val) => setState(() => _pgRating = val!),
                        requiredErrorMsg: "Odaberite PG ocjenu.",
                      ),

                      const SizedBox(height: 16),
                      _buildGenreSelectionField(),

                      const SizedBox(height: 16),

                      Text(
                        "Glumci (opcionalno)",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children:
                            _actors.map((actor) {
                              final isSelected = _selectedActorIds.contains(
                                actor.id,
                              );
                              return FilterChip(
                                label: Text(
                                  "${actor.firstName} ${actor.lastName}",
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (actor.id == null) return;
                                    if (selected) {
                                      _selectedActorIds.add(actor.id!);
                                    } else {
                                      _selectedActorIds.remove(actor.id);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                      ),

                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _saveMovie,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          isEditMode ? "Spremi promjene" : "Dodaj film",
                        ),
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
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? requiredErrorMsg,
    String? Function(String?)? customValidator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (requiredErrorMsg != null && (value == null || value.isEmpty)) {
            return requiredErrorMsg;
          }
          if (customValidator != null) {
            return customValidator(value);
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDatePickerField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: FormField<DateTime>(
        initialValue: _releaseDate,
        validator: (date) {
          if (date == null) {
            return 'Odaberite datum izlaska.';
          }
          return null;
        },
        builder: (FormFieldState<DateTime> field) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InputDecorator(
                decoration: InputDecoration(
                  labelText: "Datum izlaska",
                  border: const OutlineInputBorder(),
                  errorText: field.errorText,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      field.value != null
                          ? DateFormat('dd.MM.yyyy').format(field.value!)
                          : "Nije odabran",
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            field.value != null
                                ? null
                                : Theme.of(context).hintColor,
                      ),
                    ),
                    TextButton(
                      child: const Text('ODABERI DATUM'),
                      onPressed: () async {
                        final now = DateTime.now();
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: field.value ?? _releaseDate ?? now,
                          firstDate: DateTime(1900),
                          lastDate: DateTime(now.year + 10),
                        );
                        if (picked != null) {
                          setState(() {
                            _releaseDate = picked;
                          });
                          field.didChange(picked);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required int currentValue,
    required Map<int, String> items,
    required ValueChanged<int?> onChanged,
    String? requiredErrorMsg,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<int>(
        value: items.containsKey(currentValue) ? currentValue : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items:
            items.entries.map((entry) {
              return DropdownMenuItem<int>(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
        onChanged: onChanged,
        validator: (value) {
          if (requiredErrorMsg != null && value == null) {
            return requiredErrorMsg;
          }
          return null;
        },
      ),
    );
  }

  Widget _buildGenreSelectionField() {
    return FormField<List<int>>(
      initialValue: _selectedGenreIds,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Odaberite barem jedan žanr.';
        }
        return null;
      },
      builder: (FormFieldState<List<int>> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Žanrovi", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children:
                  _genres.map((genre) {
                    final isSelected = field.value?.contains(genre.id) ?? false;
                    return FilterChip(
                      label: Text(genre.name ?? "Nepoznat žanr"),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (genre.id == null) return;
                        final currentSelected = List<int>.from(
                          field.value ?? [],
                        );
                        if (selected) {
                          currentSelected.add(genre.id!);
                        } else {
                          currentSelected.remove(genre.id);
                        }
                        field.didChange(currentSelected);
                        setState(() {
                          _selectedGenreIds = currentSelected;
                        });
                      },
                      selectedColor: Theme.of(
                        context,
                      ).primaryColor.withOpacity(0.2),
                      checkmarkColor: Theme.of(context).primaryColor,
                    );
                  }).toList(),
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                child: Text(
                  field.errorText!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
