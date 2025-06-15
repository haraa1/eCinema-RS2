import 'dart:io';

import 'package:ecinema_mobile/providers/base_provider.dart';
import 'package:ecinema_mobile/providers/booking_provider.dart';
import 'package:ecinema_mobile/providers/booking_state.dart';
import 'package:ecinema_mobile/providers/concession_provider.dart';
import 'package:ecinema_mobile/providers/movie_provider.dart';
import 'package:ecinema_mobile/providers/payment_provider.dart';
import 'package:ecinema_mobile/providers/user_provider.dart';
import 'package:ecinema_mobile/screens/landing_movies_screen.dart';
import 'package:ecinema_mobile/screens/login_screen.dart';
import 'package:ecinema_mobile/screens/main_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class _DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback = (_, __, ___) => true;
    return client;
  }
}

http.Client getHttpClient() {
  if (kDebugMode) {
    final ioClient = HttpClient();
    ioClient.badCertificateCallback = (_, __, ___) => true;
    return IOClient(ioClient);
  }
  return http.Client();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    HttpOverrides.global = _DevHttpOverrides();
  }

  final appHttpClient = getHttpClient();
  BaseProvider.initializeHttpClient(appHttpClient);

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    print('[main] .env not found — falling back to defaults / --dart-define');
  }

  const defineUrl = String.fromEnvironment('API_URL', defaultValue: '');
  final envUrl = dotenv.env['API_URL'] ?? '';

  String baseUrl =
      defineUrl.isNotEmpty
          ? defineUrl
          : (envUrl.isNotEmpty ? envUrl : 'http://10.0.2.2:7012/');

  if (!baseUrl.endsWith('/')) baseUrl += '/';
  BaseProvider.baseUrl = baseUrl;
  print('[main] BaseProvider.baseUrl → $baseUrl');

  final stripeKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'];
  if (stripeKey != null && stripeKey.isNotEmpty) {
    Stripe.publishableKey = stripeKey;
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LandingShowtimesController()),
        ChangeNotifierProvider(create: (_) => BookingState()),
        ChangeNotifierProvider(create: (_) => MovieProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(
          create: (_) => UserProvider()..loadCurrentUser(),
        ),
        ChangeNotifierProvider(create: (_) => ConcessionProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eCinema',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      home: const LoginScreen(),
    );
  }
}
