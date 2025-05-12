import 'dart:io';
import 'package:ecinema_mobile/providers/booking_state.dart';
import 'package:ecinema_mobile/providers/movie_provider.dart';
import 'package:ecinema_mobile/providers/user_provider.dart';
import 'package:ecinema_mobile/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecinema_mobile/screens/landing_movies_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  HttpOverrides.global = _DevHttpOverrides();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LandingShowtimesController()),
        ChangeNotifierProvider(create: (_) => BookingState()),
        ChangeNotifierProvider(create: (_) => MovieProvider()),
        ChangeNotifierProvider(
          create: (_) => UserProvider()..loadCurrentUser(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class _DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eCinema',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      home: const MainScreen(),
    );
  }
}
