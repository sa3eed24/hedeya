import 'package:flutter/material.dart';
import 'package:hedeya/screens/Event_List.dart';
import 'package:hedeya/screens/addgift.dart';
import 'package:hedeya/screens/giftlist.dart';
import 'package:hedeya/screens/home_screen.dart';
import 'package:hedeya/screens/login_page.dart';
import 'package:hedeya/screens/register_page.dart';
import 'package:hedeya/screens/splash_screen.dart';
import 'package:hedeya/screens/pledgedgifts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Failed to initialize Firebase: $e');
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hedeya',
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFFD43A2F)),
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomeScreen(),
        '/giftlist': (context) => const GiftList(
          eventId: '',
          eventName: '',
        ),
        '/addgift': (context) => AddGift(
          eventId: '',
        ),
        '/pledgedgifts': (context) => PledgedGifts(
          eventId: '',
          eventName: '',
        ),
        '/eventlist': (context) => const EventsScreen(),
      },
    );
  }
}