
// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habittracker/NotificationService.dart';
import 'package:habittracker/Screens/BottomNavbar/AddHabit.dart';
import 'package:habittracker/Screens/UserAuth/Login.dart';
import 'package:habittracker/database/DB_helper.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  DB_helper? dbref;
  List<Map<String, dynamic>> allhabitdata = [];
  List<Map<String, dynamic>> todayhabitlog = [];
  String todaydate = DateFormat("yyyy-MM-dd").format(DateTime.now());
  String? username;
  int? userId;
  bool _isLoading = true;

  final FlutterNotification notificationService = FlutterNotification();

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    dbref = DB_helper.getInstance;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    notificationService.initNotification();
    loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when HomeScreen is revisited
    if (userId != null) {
      getdata();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> loadUserData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      username = pref.getString('username');
      userId = pref.getInt('user_id');
    });
    if (userId == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please log in to continue"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      await getdata();
    }
  }

  Future<bool?> _showDeleteConfirmationDialog(String habitName) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Confirm Delete",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Are you sure you want to delete '$habitName'?",
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                "No",
                style: GoogleFonts.poppins(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                "Yes",
                style: GoogleFonts.poppins(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleHabitCompletion(Map<String, dynamic> habit) async {
    if (userId == null) return;
    int habitId = habit[DB_helper.colum_id];
    bool newStatus = todayhabitlog.firstWhere(
          (log) => log[DB_helper.colum_habit_id] == habitId,
      orElse: () => {DB_helper.colum_status: 0},
    )[DB_helper.colum_status] == 0;

    bool success = await dbref!.adddailyhabitlog(
      habitid: habitId,
      date: todaydate,
      status: newStatus ? 1 : 0,
    );

    if (success) {
      await getdata();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Habit status updated for today"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).snackBarTheme.backgroundColor,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Failed to update habit status"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> getdata() async {
    if (userId == null) return;
    setState(() {
      _isLoading = true;
    });
    allhabitdata = await dbref!.getdata(userId!);
    todayhabitlog = await dbref!.gethabitlogbydate(todaydate, userId!);
    setState(() {
      _isLoading = false;
    });
    _controller.forward(from: 0.0);
  }

  Future<bool?> _showLogoutConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Confirm Logout",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          content: Text(
            "Are you sure you want to logout?",
            style: GoogleFonts.poppins(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.redAccent.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    "No",
                    style: GoogleFonts.poppins(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    "Yes",
                    style: GoogleFonts.poppins(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> logout() async {
    bool? confirm = await _showLogoutConfirmationDialog();
    if (confirm == true) {
      SharedPreferences pref = await SharedPreferences.getInstance();
      await pref.remove("user_email");
      await pref.remove("user_id");
      await pref.remove("username");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Logged out successfully"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).snackBarTheme.backgroundColor,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Map<String, List<Map<String, dynamic>>> _groupHabitsByCategory() {
    Map<String, List<Map<String, dynamic>>> groupedHabits = {};
    for (var habit in allhabitdata) {
      String category = habit[DB_helper.column_category] ?? 'Uncategorized';
      if (!groupedHabits.containsKey(category)) {
        groupedHabits[category] = [];
      }
      groupedHabits[category]!.add(habit);
    }
    return groupedHabits;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final groupedHabits = _groupHabitsByCategory();
    final categories = groupedHabits.keys.toList();
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: userId == null
          ? Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      )
          : Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.02,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: screenHeight * .03),
                            Text(
                              "Hello,",
                              style: GoogleFonts.poppins(
                                fontSize: screenWidth * 0.05,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                            Text(
                              username ?? "User",
                              style: GoogleFonts.poppins(
                                fontSize: screenWidth * 0.065,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                themeProvider.toggleTheme();
                              },
                              icon: Icon(
                                themeProvider.isDarkMode
                                    ? Icons.light_mode
                                    : Icons.dark_mode,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                            IconButton(
                              onPressed: logout,
                              icon: Icon(
                                Icons.logout,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Column(
                      children: [
                        FutureBuilder<int>(
                          future: dbref!.getcurrentstreak(userId!),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Text(
                                "Current Streak: ...",
                                style: GoogleFonts.poppins(
                                  fontSize: screenWidth * 0.04,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                              );
                            }
                            return Text(
                              "Current Streak: ${snapshot.data ?? 0} days 🔥",
                              style: GoogleFonts.poppins(
                                fontSize: screenWidth * 0.04,
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                        ),
                        FutureBuilder<int>(
                          future: dbref!.getlongeststreak(userId!),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Text(
                                "Longest Streak: ...",
                                style: GoogleFonts.poppins(
                                  fontSize: screenWidth * 0.04,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                              );
                            }
                            return Text(
                              "Longest Streak: ${snapshot.data ?? 0} days 🏆",
                              style: GoogleFonts.poppins(
                                fontSize: screenWidth * 0.04,
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: screenWidth,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  child: _isLoading
                      ? Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                      : allhabitdata.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.list_alt_outlined,
                          size: screenWidth * 0.2,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            "No Habits Found.\nStart your journey by adding one!",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: screenWidth * 0.04,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                      : ListView.builder(
                    padding: EdgeInsets.only(
                      top: screenHeight * 0.03,
                      bottom: screenHeight * 0.01,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      String category = categories[index];
                      List<Map<String, dynamic>> habits = groupedHabits[category]!;

                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.06,
                                vertical: screenHeight * 0.01,
                              ),
                              child: Text(
                                category,
                                style: GoogleFonts.poppins(
                                  fontSize: screenWidth * 0.05,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ),
                            ...habits.map((habit) {
                              int habitId = habit[DB_helper.colum_id];
                              bool isCompletedToday = todayhabitlog.any(
                                    (log) =>
                                log[DB_helper.colum_habit_id] == habitId &&
                                    log[DB_helper.colum_status] == 1,
                              );

                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.05,
                                  vertical: screenHeight * 0.005,
                                ),
                                decoration: BoxDecoration(
                                  color: isCompletedToday
                                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                                      : Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.04,
                                    vertical: screenHeight * 0.005,
                                  ),
                                  leading: GestureDetector(
                                    onTap: () => _toggleHabitCompletion(habit),
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isCompletedToday
                                              ? Theme.of(context).colorScheme.primary
                                              : Theme.of(context).colorScheme.onSurface,
                                          width: 2,
                                        ),
                                        color: isCompletedToday
                                            ? Theme.of(context).colorScheme.primary
                                            : Colors.transparent,
                                      ),
                                      child: Icon(
                                        isCompletedToday ? Icons.check : Icons.circle_outlined,
                                        color: isCompletedToday
                                            ? Theme.of(context).colorScheme.onPrimary
                                            : Theme.of(context).colorScheme.onSurface,
                                        size: screenWidth * 0.06,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    habit[DB_helper.colum_name],
                                    style: GoogleFonts.poppins(
                                      fontSize: screenWidth * 0.042,
                                      fontWeight: FontWeight.w600,
                                      color: isCompletedToday
                                          ? Theme.of(context).colorScheme.primary
                                          : Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: screenHeight * 0.005),
                                      Text(
                                        isCompletedToday ? "Completed Today" : "Not Completed Today",
                                        style: GoogleFonts.poppins(
                                          fontSize: screenWidth * 0.035,
                                          color: isCompletedToday
                                              ? Theme.of(context).colorScheme.primary
                                              : Theme.of(context).colorScheme.onSurface,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                        onPressed: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Addhabit(
                                                habitId: habit[DB_helper.colum_id],
                                                habitName: habit[DB_helper.colum_name],
                                                category: habit[DB_helper.column_category],
                                              ),
                                            ),
                                          );
                                          await getdata();
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Theme.of(context).colorScheme.error,
                                        ),
                                        onPressed: () async {
                                          bool? confirm = await _showDeleteConfirmationDialog(
                                            habit[DB_helper.colum_name],
                                          );
                                          if (confirm == true && userId != null) {
                                            bool success = await dbref!.deletehabitdata(
                                              id: habit[DB_helper.colum_id],
                                              userid: userId!,
                                            );
                                            if (success) {
                                              await getdata();
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: const Text("Habit deleted successfully"),
                                                  backgroundColor: Theme.of(context)
                                                      .snackBarTheme
                                                      .backgroundColor,
                                                  duration: const Duration(seconds: 3),
                                                ),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: const Text("Failed to delete habit"),
                                                  backgroundColor: Theme.of(context).colorScheme.error,
                                                  duration: const Duration(seconds: 3),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}