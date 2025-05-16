import 'package:ecinema_desktop/screens/actors_screen.dart';
import 'package:ecinema_desktop/screens/bookings_screen.dart';
import 'package:ecinema_desktop/screens/cinema_halls.dart';
import 'package:ecinema_desktop/screens/cinemas_screen.dart';
import 'package:ecinema_desktop/screens/concessions_screen.dart';
import 'package:ecinema_desktop/screens/discount_screen.dart';
import 'package:ecinema_desktop/screens/genre_screen.dart';
import 'package:ecinema_desktop/screens/movies_screen.dart';
import 'package:ecinema_desktop/screens/payments_screen.dart';
import 'package:ecinema_desktop/screens/reports_screen.dart';
import 'package:ecinema_desktop/screens/seat_type_screen.dart';
import 'package:ecinema_desktop/screens/showtimes_screen.dart';
import 'package:ecinema_desktop/screens/ticket_type_screen.dart';
import 'package:ecinema_desktop/screens/user_list_screen.dart';
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
      case 4:
        currentTitle = "Hrana/Piće";
        currentScreen = const ConcessionListScreen();
        break;
      case 5:
        currentTitle = "Projekcije";
        currentScreen = const ShowtimeListScreen();
        break;
      case 6:
        currentTitle = "Korisnici";
        currentScreen = const UserListScreen();
      case 7:
        currentTitle = "Rezervacije";
        currentScreen = const BookingListScreen();
      case 8:
        currentTitle = "Žanrovi";
        currentScreen = const GenreListScreen();
        break;
      case 9:
        currentTitle = "Uplate";
        currentScreen = const PaymentListScreen();
        break;
      case 10:
        currentTitle = "Tipovi sjedišta";
        currentScreen = const SeatTypeListScreen();
      case 11:
        currentTitle = "Tipovi karata";
        currentScreen = const TicketTypeListScreen();
        break;
      case 12:
        currentTitle = "Popusti";
        currentScreen = const DiscountListScreen();
        break;
      case 13:
        currentTitle = "Izvještaji";
        currentScreen = TicketReportPage();
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
