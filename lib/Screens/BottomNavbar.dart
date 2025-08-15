import 'package:flutter/material.dart';
import 'package:habittracker/Screens/BottomNavbar/HabitCategory.dart';
import 'package:habittracker/Screens/BottomNavbar/HomeScreen.dart';
import '../database/DB_helper.dart';
import 'BottomNavbar/HabitCalender.dart'; // Import DB_helper

class Bottomnavbar extends StatefulWidget {
  const Bottomnavbar({super.key});

  @override
  State<Bottomnavbar> createState() => _BottomnavbarState();
}

class _BottomnavbarState extends State<Bottomnavbar> {
  List<Map<String, dynamic>> allhabitdata = [];
  int _selectedIndex = 1; // Set the default index to 1 for the home screen (middle)
  DB_helper? dbref; // Reference to DB_helper

  @override
  void initState() {
    super.initState();
    dbref = DB_helper.getInstance;
    _loadHabits(); // Fetch habits when the widget initializes
  }

  // Fetch all habits from the database
  Future<void> _loadHabits() async {
    List<Map<String, dynamic>> habits = await dbref!.getdata(); // Assume getAllHabits fetches all habits
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
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          Habitcategory(),
          Homescreen(),
          Habitcalender(habits: allhabitdata), // Pass the populated habits list
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Category',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}