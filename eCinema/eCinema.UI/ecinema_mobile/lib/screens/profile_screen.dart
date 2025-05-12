import 'package:ecinema_mobile/screens/landing_movies_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../providers/booking_provider.dart';
import '../models/booking.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<BookingProvider>(
          create: (_) => BookingProvider()..loadMyBookings(),
        ),
      ],
      child: const DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: _ProfileAppBar(),
          body: TabBarView(children: [_ReservationsTab(), _PreferencesTab()]),
        ),
      ),
    );
  }
}

class _ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ProfileAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 48);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: const Text('Profil'),
      bottom: const TabBar(
        tabs: [Tab(text: 'Rezervacije'), Tab(text: 'Preference')],
      ),
    );
  }
}

class _ReservationsTab extends StatelessWidget {
  const _ReservationsTab();

  @override
  Widget build(BuildContext context) {
    final userProv = context.watch<UserProvider>();
    final bookingProv = context.watch<BookingProvider>();

    final user = userProv.current;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (bookingProv.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (bookingProv.error != null) {
      return Center(child: Text(bookingProv.error!));
    }

    final List<Booking> bookings = List.of(bookingProv.items);

    if (bookings.isEmpty) {
      return const Center(child: Text('Nema rezervacija.'));
    }

    bookings.sort((a, b) => b.bookingTime.compareTo(a.bookingTime));
    final Booking active = bookings.first;
    final List<Booking> history = bookings.skip(1).toList();

    Widget bookingCard(Booking b) {
      final seats = b.tickets.map((t) => t.seatId).join(', ');
      final date =
          '${b.bookingTime.day}.${b.bookingTime.month}. '
          '${b.bookingTime.hour.toString().padLeft(2, '0')}:'
          '${b.bookingTime.minute.toString().padLeft(2, '0')}';

      return Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          title: Text('Rezervacija #${b.id}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 16),
                  const SizedBox(width: 4),
                  Text(date),
                ],
              ),
              const SizedBox(height: 4),
              if (seats.isNotEmpty)
                Row(
                  children: [
                    const Icon(Icons.event_seat, size: 16),
                    const SizedBox(width: 4),
                    Text('Sjedista: $seats'),
                  ],
                ),
            ],
          ),
          trailing: TextButton(
            onPressed: () {
              // todo
            },
            child: const Text('Pregled karte'),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              const SizedBox(height: 8),
              Text(
                user.fullName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                user.email,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text('Aktivno', style: Theme.of(context).textTheme.titleSmall),
          bookingCard(active),
          const SizedBox(height: 16),

          if (history.isNotEmpty)
            Text('Historija', style: Theme.of(context).textTheme.titleSmall),
          ...history.map(bookingCard),
        ],
      ),
    );
  }
}

class _PreferencesTab extends StatefulWidget {
  const _PreferencesTab();
  @override
  State<_PreferencesTab> createState() => _PreferencesTabState();
}

class _PreferencesTabState extends State<_PreferencesTab> {
  final List<String> _languages = ['English', 'Enggg'];
  String? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    final userLang = context.read<UserProvider>().current?.preferredLanguage;
    _selectedLanguage = _languages.contains(userLang) ? userLang : null;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().current;
    if (user == null) return const Center(child: CircularProgressIndicator());

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value:
                _languages.contains(_selectedLanguage)
                    ? _selectedLanguage
                    : null,
            decoration: const InputDecoration(labelText: 'Preferirana jezik'),
            items:
                _languages
                    .map(
                      (lang) =>
                          DropdownMenuItem(value: lang, child: Text(lang)),
                    )
                    .toList(),
            onChanged: (lang) => setState(() => _selectedLanguage = lang),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed:
                (_selectedLanguage == null ||
                        _selectedLanguage == user.preferredLanguage)
                    ? null
                    : () async {
                      try {
                        await context.read<UserProvider>().updatePreferences(
                          _selectedLanguage!,
                        );
                        context.read<LandingShowtimesController>().load(
                          language: _selectedLanguage,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Preference sačuvane')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    },
            child: const Text('Sačuvaj'),
          ),
        ],
      ),
    );
  }
}
