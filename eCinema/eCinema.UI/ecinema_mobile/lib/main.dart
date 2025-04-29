// lib/main.dart
import 'package:ecinema_mobile/screens/landing_movies_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        /// Registers one global ChangeNotifier so the screen
        /// (and anything below it) can `context.watch<LandingShowtimesController>()`.
        ChangeNotifierProvider(create: (_) => LandingShowtimesController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eCinema',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      home: const LandingShowtimesScreen(),
    );
  }
}
