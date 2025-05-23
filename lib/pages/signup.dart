import 'package:flutter/material.dart';
import 'package:booking_event/services/auth.dart'; // Ensure this path is correct
import '../admin/login.dart';
import 'bottomnav.dart';
import 'home.dart'; // If you need this


class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final AuthMethods _authMethods = AuthMethods();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset("images/onboarding.png"),
              const SizedBox(height: 10.0),
              const Text(
                "Unlock The Future of",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "Event Booking App",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xff6351ec),
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30.0),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Discover, book, experience unforgettable moments effortlessly",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black45, fontSize: 20),
                ),
              ),
              const SizedBox(height: 30.0),

              // Google Sign-In Button
              GestureDetector(
                onTap: () async {
                  var user = await _authMethods.signInWithGoogle(context);
                  if (user != null) {
                    print("User signed in: ${user.email}");
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BottomNav(),
                      ),
                    );
                  } else {
                    print("Sign-in failed or cancelled.");
                  }
                },
                child: Container(
                  height: 70,
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  decoration: BoxDecoration(
                    color: const Color(0xff6351ec),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "images/google.png",
                        height: 30,
                        width: 30,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 20.0),
                      const Text(
                        "Sign in with Google",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10.0),

              // Admin Panel Button
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminLogin()),
                  );
                },
                child: const Text(
                  "Admin Panel",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,

                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
