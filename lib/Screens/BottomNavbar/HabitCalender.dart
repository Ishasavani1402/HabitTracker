import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../database/DB_helper.dart';
import '../UserAuth/Login.dart'; // Import Login screen

class Habitcalender extends StatefulWidget {
  final List<Map<String, dynamic>> habits;

  const Habitcalender({super.key, required this.habits});

  @override
  State<Habitcalender> createState() => _HabitcalenderState();
}

class _HabitcalenderState extends State<Habitcalender> {
  DB_helper? dbref;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Map<String, dynamic>> _selectedDayLogs = [];
  CalendarFormat _calendarFormat = CalendarFormat.month;
  int? userId; // NEW: Store user_id

  @override
  void initState() {
    super.initState();
    dbref = DB_helper.getInstance;
    _selectedDay = _focusedDay;
    _loadUserIdAndLogs(); // NEW: Load user_id and logs
  }

  // NEW: Load user_id from SharedPreferences and then fetch logs
  Future<void> _loadUserIdAndLogs() async {
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
          content: Text("Please log in to continue"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    await _loadSelectedDayLogs();
  }

  Future<void> _loadSelectedDayLogs() async {
    if (_selectedDay != null && userId != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDay!);
      _selectedDayLogs = await dbref!.gethabitlogbydate(formattedDate, userId!); // Pass userId
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: userId == null
          ? Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      )
          : Container(
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
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom Header
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.02,
                ),
                child: Row(
                  children: [
                    Text(
                      "Habit Calendar",
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.065,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              // Main content area
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(screenWidth * 0.05),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
                            ),
                            child: TableCalendar(
                              focusedDay: _focusedDay,
                              firstDay: DateTime.utc(2020, 1, 1),
                              lastDay: DateTime.utc(2030, 12, 31),
                              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                              onDaySelected: (selectedDay, focusedDay) {
                                setState(() {
                                  _selectedDay = selectedDay;
                                  _focusedDay = focusedDay;
                                });
                                _loadSelectedDayLogs();
                              },
                              calendarFormat: _calendarFormat,
                              onFormatChanged: (format) {
                                setState(() {
                                  _calendarFormat = format;
                                });
                              },
                              availableCalendarFormats: {
                                CalendarFormat.month: 'Month',
                                CalendarFormat.twoWeeks: '2 Weeks',
                                CalendarFormat.week: 'Week',
                              },
                              calendarStyle: CalendarStyle(
                                todayDecoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                selectedDecoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.secondary,
                                  shape: BoxShape.circle,
                                ),
                                defaultTextStyle:
                                GoogleFonts.poppins(color: Theme.of(context).colorScheme.onSurface),
                                weekendTextStyle: GoogleFonts.poppins(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                                selectedTextStyle:
                                GoogleFonts.poppins(color: Theme.of(context).colorScheme.onPrimary),
                                todayTextStyle: GoogleFonts.poppins(color: Theme.of(context).colorScheme.onPrimary),
                              ),
                              headerStyle: HeaderStyle(
                                formatButtonVisible: true,
                                formatButtonShowsNext: false,
                                formatButtonDecoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                formatButtonTextStyle: GoogleFonts.poppins(
                                  color: Theme.of(context).colorScheme.secondary,
                                  fontSize: screenWidth * 0.04,
                                ),
                                titleCentered: true,
                                titleTextStyle: GoogleFonts.poppins(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                                leftChevronIcon:
                                Icon(Icons.chevron_left, color: Theme.of(context).colorScheme.secondary),
                                rightChevronIcon:
                                Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.secondary),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                          child: Text(
                            "Logs for ${DateFormat('MMM dd, yyyy').format(_selectedDay!)}",
                            style: GoogleFonts.poppins(
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Expanded(
                          child: _selectedDayLogs.isNotEmpty
                              ? ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                            itemCount: _selectedDayLogs.length,
                            itemBuilder: (context, index) {
                              int habitId = _selectedDayLogs[index][DB_helper.colum_habit_id];
                              var habit = widget.habits.firstWhere(
                                    (h) => h[DB_helper.colum_id] == habitId,
                                orElse: () => {},
                              );
                              if (habit.isEmpty) return const SizedBox.shrink();
                              bool isCompleted = _selectedDayLogs[index][DB_helper.colum_status] == 1;

                              return Container(
                                margin: EdgeInsets.symmetric(vertical: screenHeight * 0.005),
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                                      : Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding:
                                  EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                                  title: Text(
                                    habit[DB_helper.colum_name] ?? "Unknown Habit",
                                    style: GoogleFonts.poppins(
                                      fontSize: screenWidth * 0.045,
                                      fontWeight: FontWeight.w500,
                                      color: isCompleted
                                          ? Theme.of(context).colorScheme.primary
                                          : Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                  trailing: Icon(
                                    isCompleted ? Icons.check_circle_outline : Icons.cancel_outlined,
                                    color: isCompleted
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.error,
                                    size: screenWidth * 0.06,
                                  ),
                                ),
                              );
                            },
                          )
                              : Center(
                            child: Text(
                              "No habit logs for this day.",
                              style: GoogleFonts.poppins(
                                fontSize: screenWidth * 0.04,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ));

  }
}