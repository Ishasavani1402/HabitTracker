import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habittracker/NotificationService.dart';
import 'package:habittracker/Screens/BottomNavbar/AddHabit.dart';
import 'package:habittracker/Screens/UserAuth/Login.dart';
import 'package:habittracker/database/DB_helper.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> with SingleTickerProviderStateMixin {
  DB_helper? dbref;
  List<Map<String, dynamic>> allhabitdata = [];
  List<Map<String, dynamic>> todayhabitlog = [];
  String todaydate = DateFormat("yyyy-MM-dd").format(DateTime.now());
  String? username;
  bool _isLoading = true;

  final NotificationService notificationService = NotificationService();


  // Animation Controller
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  // Define the colors for the gradient
  final Color startColor = const Color(0xFF667eea);
  final Color endColor = const Color(0xFF764ba2);

  @override
  void initState() {
    super.initState();
    dbref = DB_helper.getInstance;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    notificationService.init();
    getdata();
    loadusername();
    scheduleReminderNotifications();
  }
  Future<void> scheduleReminderNotifications() async {
    for (var habit in allhabitdata) {
      int habitId = habit[DB_helper.colum_id];
      String habitName = habit[DB_helper.colum_name];
      bool isMissing = await dbref!.isHabitStatusMissing(habitId, todaydate);
      if (isMissing) {
        await notificationService.scheduleReminderNotification(habitId, habitName);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool?> _showDeleteConfirmationDialog(String habitName) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                style: GoogleFonts.poppins(color: endColor),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                "Yes",
                style: GoogleFonts.poppins(color: startColor),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleHabitCompletion(Map<String, dynamic> habit) async {
    int habitId = habit[DB_helper.colum_id];
    bool newStatus = todayhabitlog
        .firstWhere(
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
        const SnackBar(
          content: Text("Habit status updated for today"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to update habit status"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> getdata() async {
    setState(() {
      _isLoading = true;
    });
    allhabitdata = await dbref!.getdata();
    todayhabitlog = await dbref!.gethabitlogbydate(todaydate);
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            "Confirm Logout",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Are you sure you want to logout?",
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                "No",
                style: GoogleFonts.poppins(color: endColor),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                "Yes",
                style: GoogleFonts.poppins(color: startColor),
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Logged out successfully"),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,),
      );
    }
  }

  Future<void> loadusername() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    username = pref.getString('username');
    setState(() {});
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

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [startColor.withOpacity(0.9), endColor.withOpacity(0.9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom AppBar Section
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.02,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hello,",
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.05,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          username ?? "User",
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.065,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: logout,
                      icon: const Icon(Icons.logout, color: Colors.white),
                    ),
                  ],
                ),
              ),
              // Main content area with white background
              Expanded(
                child: Container(
                  width: screenWidth,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
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
                        ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF667eea),
                      ),
                    )
                        : allhabitdata.isNotEmpty
                        ? ListView.builder(
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
                                    color: endColor,
                                  ),
                                ),
                              ),
                              ...habits.map((habit) {
                                int habitId = habit[DB_helper.colum_id];
                                bool isCompletedToday = todayhabitlog.any(
                                      (log) => log[DB_helper.colum_habit_id] == habitId && log[DB_helper.colum_status] == 1,
                                );
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.05,
                                    vertical: screenHeight * 0.005,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isCompletedToday ? startColor.withOpacity(0.1) : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
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
                                            color: isCompletedToday ? startColor : Colors.grey.shade400,
                                            width: 2,
                                          ),
                                          color: isCompletedToday ? startColor : Colors.transparent,
                                        ),
                                        child: Icon(
                                          isCompletedToday ? Icons.check : Icons.circle_outlined,
                                          color: isCompletedToday ? Colors.white : Colors.grey.shade400,
                                          size: screenWidth * 0.06,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      habit[DB_helper.colum_name],
                                      style: GoogleFonts.poppins(
                                        fontSize: screenWidth * 0.042,
                                        fontWeight: FontWeight.w600,
                                        color: isCompletedToday ? startColor
                                            : Colors.black87,
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
                                            color: isCompletedToday ? startColor : Colors.grey[600],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit, color: startColor),
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
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () async {
                                            bool? confirm = await _showDeleteConfirmationDialog(habit[DB_helper.colum_name]);
                                            if (confirm == true) {
                                              bool success = await dbref!.deletehabitdata(id: habit[DB_helper.colum_id]);
                                              if (success) {
                                                await getdata();
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text("Habit deleted successfully")),
                                                );
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text("Failed to delete habit")),
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
                              // SizedBox(height: screenHeight * 0.02),
                            ],
                          ),
                        );
                      },
                    )
                        : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.list_alt_outlined,
                            size: screenWidth * 0.2,
                            color: Colors.grey[300],
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Text(
                              "No Habits Found.\nStart your journey by adding one!",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: screenWidth * 0.04,
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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