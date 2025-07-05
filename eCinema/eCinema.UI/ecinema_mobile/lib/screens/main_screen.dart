import 'package:flutter/material.dart';
import 'landing_movies_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final GlobalKey<ProfileScreenState> _profileScreenKey =
      GlobalKey<ProfileScreenState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [LandingShowtimesScreen(), ProfileScreen(key: _profileScreenKey)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() => _currentIndex = i);

          if (i == 1) {
            final profileState = _profileScreenKey.currentState;

            if (profileState != null && profileState.mounted) {
              print(
                "MainScreen: Switched to Profile tab. Requesting data refresh.",
              );
              profileState.refreshBookingsIfReservationsTabActive();
            } else {
              print(
                "MainScreen: Switched to Profile tab, but profileState is null or not mounted. Cannot refresh.",
              );
            }
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Filmovi'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
