
// ignore_for_file: file_names, no_leading_underscores_for_local_identifiers, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habittracker/Screens/BottomNavbar/HabitCategory.dart';
import 'package:habittracker/Screens/BottomNavbar/HomeScreen.dart';
import 'package:habittracker/Screens/UserAuth/Login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/DB_helper.dart';
import 'BottomNavbar/HabitCalender.dart';

class Bottomnavbar extends StatefulWidget {
final int selectedIndex; // NEW: Optional parameter for initial tab

const Bottomnavbar({super.key, this.selectedIndex = 1});

@override
State<Bottomnavbar> createState() => _BottomnavbarState();
}

class _BottomnavbarState extends State<Bottomnavbar> {
List<Map<String, dynamic>> allhabitdata = [];
late int _selectedIndex;
DB_helper? dbref;
int? userId; // NEW: Store user_id

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
_selectedIndex = widget.selectedIndex; // Initialize with passed index
dbref = DB_helper.getInstance;
_loadUserIdAndHabits(); // NEW: Load user_id and habits
}

// NEW: Load user_id from SharedPreferences and then fetch habits
Future<void> _loadUserIdAndHabits() async {
SharedPreferences pref = await SharedPreferences.getInstance();
setState(() {
userId = pref.getInt('user_id');
});

if (userId == null) {
// Redirect to Login screen if user_id is not found
Navigator.pushReplacement(
context,
MaterialPageRoute(builder: (context) => const Login()),
);
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: const Text("Please log in to continue"),
behavior: SnackBarBehavior.floating,
backgroundColor: Theme.of(context).colorScheme.error,
),
);
return;
}

await _loadHabits();
}

Future<void> _loadHabits() async {
if (userId == null) return; // Prevent fetching if user_id is not set
List<Map<String, dynamic>> habits = await dbref!.getdata(userId!); // Pass userId
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
const Habitcategory(),
const HomeScreen(),
Habitcalender(habits: allhabitdata),
];

return Scaffold(
backgroundColor: Theme.of(context).scaffoldBackgroundColor,
body: userId == null
? Center(
child: CircularProgressIndicator(
color: Theme.of(context).colorScheme.primary,
),
)
    : _screens[_selectedIndex],
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
selectedItemColor: Theme.of(context).colorScheme.onPrimary,
unselectedItemColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.6),
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
? Theme.of(context).colorScheme.onPrimary.withOpacity(0.2)
    : Colors.transparent,
borderRadius: BorderRadius.circular(15),
),
child: Icon(
_icons[index],
size: 24,
color: _selectedIndex == index
? Theme.of(context).colorScheme.onPrimary
    : Theme.of(context).colorScheme.onPrimary.withOpacity(0.6),
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