import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'firebase_options.dart';
import 'package:booking_event/pages/signup.dart';      // Your signup/login page
import 'package:booking_event/pages/bottomnav.dart';  // Your main page after login

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Stripe setup
  Stripe.publishableKey = 'pk_test_51ROgSiPxHNNQUnVYGqaxvp2x4bgvMRZXZcio1eK9Vmx6xAHIeWnQ8xRJ3Of5JS0T7uzvbKArbibbqDB0YuBKZVxi00HMmHUsvL';
  await Stripe.instance.applySettings();

  // Firebase initialization
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Firebase App Check
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Event Booking App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          // User is signed in
          return const BottomNav();
        } else {
          // Not signed in
          return const Signup();
        }
      },
    );
  }
}
