import 'package:ecinema_desktop/screens/actors_screen.dart';
import 'package:ecinema_desktop/screens/cinema_halls.dart';
import 'package:ecinema_desktop/screens/cinemas_screen.dart';
import 'package:ecinema_desktop/screens/movies_screen.dart';
import 'package:ecinema_desktop/widgets/admin_scaffold.dart';
import 'package:flutter/material.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget currentScreen;
    String currentTitle;

    switch (_selectedIndex) {
      case 0:
        currentTitle = "Filmovi";
        currentScreen = const MovieListScreen();
        break;
      case 1:
        currentTitle = "Glumci";
        currentScreen = const ActorListScreen();
        break;
      case 2:
        currentTitle = "Kina";
        currentScreen = const CinemaListScreen();
        break;
      case 3:
        currentTitle = "Dvorane";
        currentScreen = const CinemaHallListScreen();
        break;
      default:
        currentTitle = "Početna";
        currentScreen = const Center(child: Text("Nepoznata sekcija"));
    }

    return AdminScaffold(
      title: currentTitle,
      body: currentScreen,
      selectedIndex: _selectedIndex,
      onMenuTap: (index) => setState(() => _selectedIndex = index),
    );
  }
}
