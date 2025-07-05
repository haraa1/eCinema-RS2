import 'package:ecinema_mobile/providers/base_provider.dart';
import 'package:ecinema_mobile/screens/landing_movies_screen.dart';
import 'package:ecinema_mobile/widgets/profile_update_dialog.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../providers/user_provider.dart';
import '../providers/booking_provider.dart';
import '../models/booking.dart';
import '../models/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BookingProvider _bookingProvider = BookingProvider();
  bool _isUploadingPicture = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<UserProvider>(
          context,
          listen: false,
        ).loadCurrentUser().then((_) {
          if (mounted && _tabController.index == 0) {
            _bookingProvider.loadMyBookings();
          }
        });
      }
    });

    _tabController.addListener(() {
      if (mounted && !_tabController.indexIsChanging) {
        if (_tabController.index == 0) {
          Provider.of<UserProvider>(
            context,
            listen: false,
          ).loadCurrentUser().then((_) {
            _bookingProvider.loadMyBookings();
          });
        } else if (_tabController.index == 1) {
          Provider.of<UserProvider>(context, listen: false).loadCurrentUser();
        }
      }
    });
  }

  void refreshBookingsIfReservationsTabActive() {
    if (mounted && _tabController.index == 0) {
      Provider.of<UserProvider>(context, listen: false).loadCurrentUser().then((
        _,
      ) {
        _bookingProvider.loadMyBookings();
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bookingProvider.dispose();
    super.dispose();
  }

  void _showProfileUpdateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const ProfileUpdateDialog();
      },
    );
  }

  Future<void> _handleProfilePictureChange() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.current == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        _isUploadingPicture = true;
      });

      try {
        final imageFile = File(pickedFile.path);
        await userProvider.updateProfilePicture(imageFile);

        await userProvider.loadCurrentUser();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Slika profila je uspješno ažurirana."),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Greška: $e")));
        }
      } finally {
        if (mounted) {
          setState(() {
            _isUploadingPicture = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BookingProvider>.value(
      value: _bookingProvider,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Profil'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                final user =
                    Provider.of<UserProvider>(context, listen: false).current;
                if (user != null) {
                  _showProfileUpdateDialog();
                } else {
                  Provider.of<UserProvider>(
                    context,
                    listen: false,
                  ).loadCurrentUser().then((_) {
                    if (Provider.of<UserProvider>(
                          context,
                          listen: false,
                        ).current !=
                        null) {
                      _showProfileUpdateDialog();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Korisnički podaci se učitavaju, pokušajte ponovo.",
                          ),
                        ),
                      );
                    }
                  });
                }
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [Tab(text: 'Rezervacije'), Tab(text: 'Preference')],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _ReservationsTab(
              onEditProfile: _showProfileUpdateDialog,
              onChangePicture: _handleProfilePictureChange,
              isUploading: _isUploadingPicture,
            ),
            _PreferencesTab(),
          ],
        ),
      ),
    );
  }
}

class _ReservationsTab extends StatelessWidget {
  final VoidCallback onEditProfile;
  final VoidCallback onChangePicture;
  final bool isUploading;

  const _ReservationsTab({
    required this.onEditProfile,
    required this.onChangePicture,
    required this.isUploading,
  });

  @override
  Widget build(BuildContext context) {
    final userProv = context.watch<UserProvider>();
    final bookingProv = context.watch<BookingProvider>();
    final user = userProv.current;

    if (user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Molimo prijavite se ili provjerite internet konekciju.",
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => context.read<UserProvider>().loadCurrentUser(),
              child: const Text("Učitaj profil"),
            ),
          ],
        ),
      );
    }

    if (bookingProv.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (bookingProv.error != null) {
      return Center(child: Text(bookingProv.error!));
    }

    final List<Booking> bookings =
        bookingProv.items != null ? List.of(bookingProv.items!) : [];
    bookings.sort((a, b) => b.bookingTime.compareTo(a.bookingTime));
    final Booking? active = bookings.isNotEmpty ? bookings.first : null;
    final List<Booking> history =
        bookings.isNotEmpty ? bookings.skip(1).toList() : [];

    Widget bookingCard(Booking b) {
      final seats = b.tickets
          .map((t) => t.seatId?.toString() ?? '?')
          .join(', ');
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
                    Text('Sjedišta: $seats'),
                  ],
                ),
            ],
          ),
        ),
      );
    }

    Widget buildAvatar(User user) {
      ImageProvider? backgroundImage;

      if (user.profilePicture != null && user.profilePicture!.isNotEmpty) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final imageUrl =
            '${BaseProvider.baseUrl}User/${user.id}/profile-picture?v=$timestamp';

        backgroundImage = NetworkImage(
          imageUrl,
          headers: BaseProvider.createHeaders(),
        );
      }

      return Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: backgroundImage,
            backgroundColor: Colors.grey.shade300,
            child:
                backgroundImage == null
                    ? Icon(Icons.person, size: 50, color: Colors.grey.shade800)
                    : null,
          ),
          Material(
            color: Theme.of(context).primaryColor,
            shape: const CircleBorder(),
            elevation: 2,
            child: InkWell(
              onTap: onChangePicture,
              customBorder: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(6.0),
                child: Icon(Icons.edit, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isUploading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            )
          else
            Center(child: buildAvatar(user)),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                user.fullName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                user.email,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
              if (user.phoneNumber.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    user.phoneNumber,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          if (active == null && history.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Text('Nema rezervacija.'),
              ),
            ),
          if (active != null) ...[
            Text('Aktivno', style: Theme.of(context).textTheme.titleSmall),
            bookingCard(active),
            const SizedBox(height: 16),
          ],
          if (history.isNotEmpty) ...[
            Text('Historija', style: Theme.of(context).textTheme.titleSmall),
            ...history.map(bookingCard),
          ],
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
  static const List<String> _languages = [
    'English',
    'Bosnian',
    'Croatian',
    'Serbian',
  ];
  String? _selectedLanguage;
  bool _isSavingNotifications = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final user = context.read<UserProvider>().current;
        if (user?.preferredLanguage != null &&
            _languages.contains(user!.preferredLanguage)) {
          setState(() {
            _selectedLanguage = user.preferredLanguage;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.current;

    if (user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Korisnički podaci se učitavaju..."),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => context.read<UserProvider>().loadCurrentUser(),
              child: const Text("Pokušaj ponovo"),
            ),
          ],
        ),
      );
    }

    if (_selectedLanguage == null &&
        user.preferredLanguage != null &&
        _languages.contains(user.preferredLanguage)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedLanguage = user.preferredLanguage;
          });
        }
      });
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedLanguage,
            decoration: const InputDecoration(labelText: 'Preferirani jezik'),
            items:
                _languages
                    .map(
                      (lang) =>
                          DropdownMenuItem(value: lang, child: Text(lang)),
                    )
                    .toList(),
            onChanged: (lang) => setState(() => _selectedLanguage = lang),
            hint:
                _selectedLanguage == null
                    ? const Text("Odaberite jezik")
                    : null,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed:
                (_selectedLanguage == null ||
                        _selectedLanguage == user.preferredLanguage)
                    ? null
                    : () async {
                      try {
                        await userProvider.updateProfile(
                          preferredLanguage: _selectedLanguage!,
                        );
                        if (mounted) {
                          context.read<LandingShowtimesController>().load(
                            language: _selectedLanguage,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Preferirani jezik sačuvan'),
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Greška: $e')));
                        }
                      }
                    },
            child: const Text('Sačuvaj jezik'),
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          SwitchListTile(
            title: const Text('Primajte obavijesti putem e-pošte'),
            value: user.notify,
            onChanged:
                _isSavingNotifications
                    ? null
                    : (bool value) async {
                      setState(() {
                        _isSavingNotifications = true;
                      });
                      try {
                        await userProvider.updateNotificationSettings(value);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Postavke obavijesti su sačuvane.'),
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Greška: $e')));
                          userProvider.loadCurrentUser();
                        }
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isSavingNotifications = false;
                          });
                        }
                      }
                    },
            secondary:
                _isSavingNotifications
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    )
                    : const Icon(Icons.email_outlined),
          ),
        ],
      ),
    );
  }
}
