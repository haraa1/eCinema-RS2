import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ecinema_desktop/models/movie.dart';
import 'package:ecinema_desktop/models/cinema_hall.dart';
import 'package:ecinema_desktop/models/showtime.dart';
import 'package:ecinema_desktop/providers/movie_provider.dart';
import 'package:ecinema_desktop/providers/cinema_hall_provider.dart';
import 'package:ecinema_desktop/providers/showtime_provider.dart';

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

  int? _selectedMovieId;
  int? _selectedCinemaHallId;
  DateTime? _startTime;
  DateTime? _endTime;

  @override
  void initState() {
    super.initState();
    _loadInitialData();

    if (widget.showtime != null) {
      _selectedMovieId = widget.showtime!.movieId;
      _selectedCinemaHallId = widget.showtime!.cinemaHallId;
      _startTime = widget.showtime!.startTime;
      _endTime = widget.showtime!.endTime;
      _priceController.text = widget.showtime!.basePrice?.toString() ?? '';
    }
  }

  Future<void> _loadInitialData() async {
    final movieResult = await _movieProvider.get();
    final hallResult = await _cinemaHallProvider.get();

    setState(() {
      _movies = movieResult.result;
      _cinemaHalls = hallResult.result;
    });
  }

  Future<void> _saveShowtime() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startTime == null ||
        _endTime == null ||
        _selectedMovieId == null ||
        _selectedCinemaHallId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Sva polja su obavezna")));
      return;
    }

    final request = {
      "movieId": _selectedMovieId,
      "cinemaHallId": _selectedCinemaHallId,
      "startTime": _startTime!.toIso8601String(),
      "endTime": _endTime!.toIso8601String(),
      "basePrice": double.tryParse(_priceController.text),
    };

    try {
      if (widget.showtime == null) {
        await _showtimeProvider.insert(request);
      } else {
        await _showtimeProvider.update(widget.showtime!.id!, request);
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Greška pri spremanju: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year),
      lastDate: DateTime(now.year + 2),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
    );

    if (time == null) return;

    final selected = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isStart) {
        _startTime = selected;
      } else {
        _endTime = selected;
      }
    });
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.showtime != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Uredi projekciju" : "Dodaj projekciju"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: "Film",
                  border: OutlineInputBorder(),
                ),
                value: _selectedMovieId,
                items:
                    _movies
                        .map(
                          (m) => DropdownMenuItem(
                            value: m.id,
                            child: Text(m.title ?? ""),
                          ),
                        )
                        .toList(),
                onChanged: (val) => setState(() => _selectedMovieId = val),
                validator: (val) => val == null ? 'Obavezno polje' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: "Sala",
                  border: OutlineInputBorder(),
                ),
                value: _selectedCinemaHallId,
                items:
                    _cinemaHalls
                        .map(
                          (h) => DropdownMenuItem(
                            value: h.id,
                            child: Text(h.name ?? ""),
                          ),
                        )
                        .toList(),
                onChanged: (val) => setState(() => _selectedCinemaHallId = val),
                validator: (val) => val == null ? 'Obavezno polje' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: "Osnovna cijena",
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator:
                    (value) =>
                        (value == null || value.isEmpty)
                            ? 'Obavezno polje'
                            : null,
              ),
              const SizedBox(height: 16),
              _buildDateTimeField(
                "Početak",
                _startTime,
                () => _pickDateTime(isStart: true),
              ),
              const SizedBox(height: 16),
              _buildDateTimeField(
                "Kraj",
                _endTime,
                () => _pickDateTime(isStart: false),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveShowtime,
                child: Text(isEdit ? "Spremi promjene" : "Spremi projekciju"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeField(
    String label,
    DateTime? value,
    VoidCallback onTap,
  ) {
    final text =
        value != null
            ? DateFormat('yyyy-MM-dd HH:mm').format(value)
            : "Odaberi vrijeme";
    return GestureDetector(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Text(text),
      ),
    );
  }
}
