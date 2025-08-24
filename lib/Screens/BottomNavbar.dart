// ignore_for_file: file_names, no_leading_underscores_for_local_identifiers, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habittracker/Screens/BottomNavbar/HabitCategory.dart';
import 'package:habittracker/Screens/BottomNavbar/HomeScreen.dart';
import '../database/DB_helper.dart';
import 'BottomNavbar/HabitCalender.dart';

class Bottomnavbar extends StatefulWidget {
  const Bottomnavbar({super.key});

  @override
  State<Bottomnavbar> createState() => _BottomnavbarState();
}

class _BottomnavbarState extends State<Bottomnavbar> {
  List<Map<String, dynamic>> allhabitdata = [];
  int _selectedIndex = 1;
  DB_helper? dbref;

  final List<IconData> _icons = [
    Icons.category,
    Icons.home,
    Icons.calendar_today,
  ];

  final List<String> _labels = [
    'Category',
    'Home',
    'Calendar',
  ];

  @override
  void initState() {
    super.initState();
    dbref = DB_helper.getInstance;
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    List<Map<String, dynamic>> habits = await dbref!.getdata();
    setState(() {
      allhabitdata = habits;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      Habitcategory(),
      const HomeScreen(),
      Habitcalender(habits: allhabitdata),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Ensure consistent background
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
              Theme.of(context).colorScheme.secondary.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: Theme.of(context).colorScheme.onPrimary, // Use onPrimary for contrast
            unselectedItemColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.6), // Slightly faded for unselected
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
            unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
            items: List.generate(
              _icons.length,
                  (index) => BottomNavigationBarItem(
                icon: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: _selectedIndex == index
                        ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.2) // Use onPrimary for selected background
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    _icons[index],
                    size: 24,
                    color: _selectedIndex == index
                        ? Theme.of(context).colorScheme.onPrimary // Selected icon color
                        : Theme.of(context).colorScheme.onPrimary.withOpacity(0.6), // Unselected icon color
                  ),
                ),
                label: _labels[index],
              ),
            ),
          ),
        ),
      ),
    );
  }
}