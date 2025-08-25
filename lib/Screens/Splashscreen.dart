import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:habittracker/Screens/UserAuth/Login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'BottomNavbar.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 3));

    SharedPreferences pref = await SharedPreferences.getInstance();
    String? email = pref.getString('user_email');
    print("splash screen user email: $email");

    if (email != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Bottomnavbar()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Theme-aware background
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
              Theme.of(context).colorScheme.secondary.withOpacity(0.8),
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.8), // Third color for gradient
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.check_mark_circled_solid,
                color: Theme.of(context).colorScheme.onPrimary, // Theme-aware icon color
                size: 100.0,
              ),
              const SizedBox(height: 24.0),
              Text(
                'Habit Tracker',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary, // Theme-aware text color
                  fontSize: 36.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Build better habits, one day at a time.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7), // Theme-aware text color
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 48.0),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary), // Theme-aware loader color
              ),
            ],
          ),
        ),
      ),
    );
  }
}