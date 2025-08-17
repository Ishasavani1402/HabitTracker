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
    return Scaffold(
      extendBody: true, // This is key to making the body extend behind the navigation bar
      body: Stack(
        children: [
          // Main screen content (takes up all available space)
          IndexedStack(
            index: _selectedIndex,
            children: [
              Habitcategory(),
              const Homescreen(),
              Habitcalender(habits: allhabitdata),
            ],
          ),
          // Custom Bottom Navigation Bar positioned at the bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 80,
              // margin: const EdgeInsets.symmetric(horizontal: 10,),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [startColor, endColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  _icons.length,
                      (index) {
                    final isSelected = _selectedIndex == index;
                    return Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => _onItemTapped(index),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Icon(
                                    _icons[index],
                                    color: isSelected ? Colors.white : Colors.white70,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _labels[index],
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected ? Colors.white : Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}