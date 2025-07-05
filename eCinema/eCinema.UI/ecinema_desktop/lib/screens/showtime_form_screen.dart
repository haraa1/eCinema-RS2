import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ecinema_desktop/models/movie.dart';
import 'package:ecinema_desktop/models/cinema_hall.dart';
import 'package:ecinema_desktop/models/showtime.dart';
import 'package:ecinema_desktop/providers/movie_provider.dart';
import 'package:ecinema_desktop/providers/cinema_hall_provider.dart';
import 'package:ecinema_desktop/providers/showtime_provider.dart';
import 'package:flutter/services.dart';

class ShowtimeFormScreen extends StatefulWidget {
  final Showtime? showtime;

  const ShowtimeFormScreen({super.key, this.showtime});

  @override
  State<ShowtimeFormScreen> createState() => _ShowtimeFormScreenState();
}

class _ShowtimeFormScreenState extends State<ShowtimeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();

  final _movieProvider = MovieProvider();
  final _cinemaHallProvider = CinemaHallProvider();
  final _showtimeProvider = ShowtimeProvider();

  List<Movie> _movies = [];
  List<CinemaHall> _cinemaHalls = [];
  bool _isLoadingDropdowns = true;

  int? _selectedMovieId;
  int? _selectedCinemaHallId;
  DateTime? _startTime;
  DateTime? _endTime;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoadingDropdowns = true);
    try {
      final movieResult = await _movieProvider.get(filter: {'pageSize': 1000});
      final hallResult = await _cinemaHallProvider.get(
        filter: {'pageSize': 1000},
      );

      if (mounted) {
        setState(() {
          _movies = movieResult.result;
          _cinemaHalls = hallResult.result;

          if (widget.showtime != null) {
            _selectedMovieId = widget.showtime!.movie!.id;
            _selectedCinemaHallId = widget.showtime!.cinemaHall!.id;
            _startTime = widget.showtime!.startTime;
            _endTime = widget.showtime!.endTime;
            _priceController.text =
                widget.showtime!.basePrice?.toStringAsFixed(2) ?? '';
          }

          _isLoadingDropdowns = false;
        });
      }
    } catch (e) {
      if (mounted) {
        print("Error loading dropdown data: $e");
        setState(() => _isLoadingDropdowns = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Greška pri učitavanju podataka: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveShowtime() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    double? price = double.tryParse(
      _priceController.text.trim().replaceAll(',', '.'),
    );

    final request = {
      "movieId": _selectedMovieId,
      "cinemaHallId": _selectedCinemaHallId,
      "startTime": _startTime!.toIso8601String(),
      "endTime": _endTime!.toIso8601String(),
      "basePrice": price,
    };

    try {
      String successMessage;
      if (widget.showtime == null) {
        await _showtimeProvider.insert(request);
        successMessage = "Projekcija uspješno dodana.";
      } else {
        await _showtimeProvider.update(widget.showtime!.id!, request);
        successMessage = "Podaci o projekciji uspješno ažurirani.";
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

  Future<void> _pickDateTime({
    required bool isStart,
    required FormFieldState<DateTime> field,
  }) async {
    final now = DateTime.now();
    DateTime initialDatePickerDate =
        field.value ?? (isStart ? _startTime : _endTime) ?? now;
    if (isStart &&
        _endTime != null &&
        initialDatePickerDate.isAfter(_endTime!)) {
      initialDatePickerDate = _endTime!;
    } else if (!isStart &&
        _startTime != null &&
        initialDatePickerDate.isBefore(_startTime!)) {
      initialDatePickerDate = _startTime!;
    }

    final date = await showDatePicker(
      context: context,
      initialDate: initialDatePickerDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );

    if (date == null || !mounted) return;

    TimeOfDay initialTimePickerTime = TimeOfDay.fromDateTime(
      field.value ?? (isStart ? _startTime : _endTime) ?? now,
    );

    final time = await showTimePicker(
      context: context,
      initialTime: initialTimePickerTime,
    );

    if (time == null || !mounted) return;

    final selectedDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isStart) {
        _startTime = selectedDateTime;

        if (_selectedMovieId != null &&
            _movies.any((m) => m.id == _selectedMovieId)) {
          final movie = _movies.firstWhere((m) => m.id == _selectedMovieId);
          if (movie.durationMinutes != null && movie.durationMinutes! > 0) {
            _endTime = _startTime!.add(
              Duration(minutes: movie.durationMinutes!),
            );
          }
        }
      } else {
        _endTime = selectedDateTime;
      }
    });
    field.didChange(selectedDateTime);
    _formKey.currentState?.validate();
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.showtime != null;

    if (_isLoadingDropdowns && _movies.isEmpty && _cinemaHalls.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isEditMode ? "Uredi projekciju" : "Dodaj projekciju"),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            semanticsLabel: "Učitavanje podataka...",
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? "Uredi projekciju" : "Dodaj projekciju"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildMovieDropdown(),
              const SizedBox(height: 16),
              _buildCinemaHallDropdown(),
              const SizedBox(height: 16),
              _buildPriceField(),
              const SizedBox(height: 16),
              _buildDateTimeFieldWrapper(
                label: "Početak projekcije",
                value: _startTime,
                isStart: true,
                validator: (value) {
                  if (value == null) return 'Odaberite vrijeme početka.';
                  if (_endTime != null && !value.isBefore(_endTime!)) {
                    return 'Početak mora biti prije kraja.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildDateTimeFieldWrapper(
                label: "Kraj projekcije",
                value: _endTime,
                isStart: false,
                validator: (value) {
                  if (value == null) return 'Odaberite vrijeme kraja.';
                  if (_startTime != null && !value.isAfter(_startTime!)) {
                    return 'Kraj mora biti nakon početka.';
                  }

                  if (_startTime != null && _selectedMovieId != null) {
                    final movie = _movies.firstWhere(
                      (m) => m.id == _selectedMovieId,
                      orElse: () => Movie(id: 0, title: ""),
                    );
                    if (movie.id != 0 &&
                        movie.durationMinutes != null &&
                        movie.durationMinutes! > 0) {
                      final expectedEndTime = _startTime!.add(
                        Duration(minutes: movie.durationMinutes!),
                      );
                      if (value.isBefore(
                            expectedEndTime.subtract(
                              const Duration(minutes: 5),
                            ),
                          ) ||
                          value.isAfter(
                            expectedEndTime.add(const Duration(minutes: 15)),
                          )) {
                        return 'Kraj nije usklađen s trajanjem filma (${movie.durationMinutes} min). Očekivano: ${DateFormat('HH:mm').format(expectedEndTime)}';
                      }
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoadingDropdowns ? null : _saveShowtime,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  isEditMode ? "Spremi promjene" : "Spremi projekciju",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMovieDropdown() {
    return DropdownButtonFormField<int>(
      value:
          _movies.any((m) => m.id == _selectedMovieId)
              ? _selectedMovieId
              : null,
      decoration: const InputDecoration(
        labelText: "Film",
        border: OutlineInputBorder(),
        hintText: "Odaberite film",
      ),
      isExpanded: true,
      items:
          _movies
              .map(
                (Movie movie) => DropdownMenuItem<int>(
                  value: movie.id,
                  child: Text(movie.title ?? "Nepoznat film"),
                ),
              )
              .toList(),
      onChanged:
          _isLoadingDropdowns
              ? null
              : (val) {
                setState(() {
                  _selectedMovieId = val;

                  if (_startTime != null && val != null) {
                    final movie = _movies.firstWhere((m) => m.id == val);
                    if (movie.durationMinutes != null &&
                        movie.durationMinutes! > 0) {
                      _endTime = _startTime!.add(
                        Duration(minutes: movie.durationMinutes!),
                      );

                      _formKey.currentState?.validate();
                    }
                  }
                });
              },
      validator: (val) => val == null ? 'Molimo odaberite film.' : null,
      disabledHint:
          _isLoadingDropdowns ? const Text("Učitavanje filmova...") : null,
      hint:
          _isLoadingDropdowns && _movies.isEmpty
              ? const Text("Učitavanje filmova...")
              : null,
    );
  }

  Widget _buildCinemaHallDropdown() {
    return DropdownButtonFormField<int>(
      value:
          _cinemaHalls.any((h) => h.id == _selectedCinemaHallId)
              ? _selectedCinemaHallId
              : null,
      decoration: const InputDecoration(
        labelText: "Dvorana",
        border: OutlineInputBorder(),
        hintText: "Odaberite dvoranu",
      ),
      isExpanded: true,
      items:
          _cinemaHalls
              .map(
                (CinemaHall hall) => DropdownMenuItem<int>(
                  value: hall.id,
                  child: Text(hall.name ?? "Nepoznata dvorana"),
                ),
              )
              .toList(),
      onChanged:
          _isLoadingDropdowns
              ? null
              : (val) => setState(() => _selectedCinemaHallId = val),
      validator: (val) => val == null ? 'Molimo odaberite dvoranu.' : null,
      disabledHint:
          _isLoadingDropdowns ? const Text("Učitavanje dvorana...") : null,
      hint:
          _isLoadingDropdowns && _cinemaHalls.isEmpty
              ? const Text("Učitavanje dvorana...")
              : null,
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      controller: _priceController,
      decoration: const InputDecoration(
        labelText: "Osnovna cijena (npr. 7.50)",
        border: OutlineInputBorder(),
        prefixText: "KM ",
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*([.,])?\d{0,2}')),
      ],
      validator: (value) {
        if (value == null || value.trim().isEmpty)
          return 'Unesite osnovnu cijenu.';
        final price = double.tryParse(value.trim().replaceAll(',', '.'));
        if (price == null) return 'Unesite validan broj za cijenu.';
        if (price <= 0) return 'Cijena mora biti veća od 0.';
        return null;
      },
    );
  }

  Widget _buildDateTimeFieldWrapper({
    required String label,
    required DateTime? value,
    required bool isStart,
    required String? Function(DateTime?) validator,
  }) {
    return FormField<DateTime>(
      initialValue: value,
      validator: validator,
      builder: (FormFieldState<DateTime> field) {
        final displayValue = field.value ?? (isStart ? _startTime : _endTime);
        final String textToShow =
            displayValue != null
                ? DateFormat('dd.MM.yyyy HH:mm').format(displayValue)
                : "Odaberite datum i vrijeme";

        return InkWell(
          onTap:
              _isLoadingDropdowns
                  ? null
                  : () => _pickDateTime(isStart: isStart, field: field),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
              errorText: field.errorText,
              suffixIcon: const Icon(Icons.calendar_today),
            ),
            child: Text(
              textToShow,
              style: TextStyle(
                fontSize: 16,
                color:
                    displayValue != null ? null : Theme.of(context).hintColor,
              ),
            ),
          ),
        );
      },
    );
  }
}
