import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:habittracker/Screens/HomeScreen.dart';
import 'package:habittracker/Screens/Registration.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    print("splash screen user email : $email");

    if (email != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Homescreen()));
    } else{
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Registration()));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            // Define the start and end of the gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            // Use a list of colors for the gradient effect
            colors: [
              Color(0xFF6A1B9A), // A deep purple
              Color(0xFF8E24AA), // A slightly lighter purple
              Color(0xFFAB47BC), // A medium purple
            ],
          ),
        ),
        child: Center(
          // Center the content in a Column
          child: Column(
            // Align items in the center of the column
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Use an Icon to represent the app's purpose (e.g., a checkmark for a habit tracker)
              const Icon(
                CupertinoIcons.check_mark_circled_solid,
                color: Colors.white,
                size: 100.0,
              ),
              const SizedBox(height: 24.0), // Add some spacing
              // Display the app's name
              const Text(
                'Habit Tracker',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 16.0), // Add more spacing
              // A simple tagline for the app
              const Text(
                'Build better habits, one day at a time.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 48.0), // Add significant spacing before the loader
              // A CircularProgressIndicator for a subtle loading animation
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
