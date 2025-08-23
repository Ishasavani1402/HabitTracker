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

  final Color startColor = const Color(0xFF667eea);
  final Color endColor = const Color(0xFF764ba2);

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
    // List of screens to be displayed
    final List<Widget> _screens = [
      Habitcategory(),
      const Homescreen(),
      Habitcalender(habits: allhabitdata),
    ];

    return Scaffold(
      // extendBody: true, // This is still important for a full-screen background
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        height: 80,
        // margin: const EdgeInsets.only(left: 10, right: 10, bottom: 20), // Adds margin to the container
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [startColor, endColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.grey.withOpacity(0.5),
          //     spreadRadius: 2,
          //     blurRadius: 10,
          //     offset: const Offset(0, 5),
          //   ),
          // ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20), // Match the container's border radius
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent, // Make the background transparent
            elevation: 0, // Remove the default shadow
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed, // Use fixed type for consistent item size
            items: List.generate(
              _icons.length,
                  (index) => BottomNavigationBarItem(
                icon: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: _selectedIndex == index ? Colors.white.withOpacity(0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(_icons[index], size: 24),
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