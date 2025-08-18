import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../database/DB_helper.dart';

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
  CalendarFormat _calendarFormat = CalendarFormat.month; // State variable for calendar format

  final Color startColor = const Color(0xFF667eea);
  final Color endColor = const Color(0xFF764ba2);

  @override
  void initState() {
    super.initState();
    dbref = DB_helper.getInstance;
    _selectedDay = _focusedDay;
    _loadSelectedDayLogs();
  }

  Future<void> _loadSelectedDayLogs() async {
    if (_selectedDay != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDay!);
      _selectedDayLogs = await dbref!.gethabitlogbydate(formattedDate);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
              // Custom Header
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.02,
                ),
                child: Row(
                  children: [
                    // IconButton(
                    //   icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    //   onPressed: () => Navigator.of(context).pop(),
                    // ),
                    // SizedBox(width: screenWidth * 0.02),
                    Text(
                      "Habit Calendar",
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.065,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(screenWidth * 0.05),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey.shade200),
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
                              calendarFormat: _calendarFormat, // Use state variable
                              onFormatChanged: (format) {
                                setState(() {
                                  _calendarFormat = format; // Update format on change
                                });
                              },
                              availableCalendarFormats: {
                                CalendarFormat.month: 'Month',
                                CalendarFormat.twoWeeks: '2 Weeks',
                                CalendarFormat.week: 'Week',
                              },
                              calendarStyle: CalendarStyle(
                                todayDecoration: BoxDecoration(
                                  color: startColor,
                                  shape: BoxShape.circle,
                                ),
                                selectedDecoration: BoxDecoration(
                                  color: endColor,
                                  shape: BoxShape.circle,
                                ),
                                defaultTextStyle: GoogleFonts.poppins(color: Colors.black87),
                                weekendTextStyle: GoogleFonts.poppins(color: Colors.black54),
                                selectedTextStyle: GoogleFonts.poppins(color: Colors.white),
                                todayTextStyle: GoogleFonts.poppins(color: Colors.white),
                              ),
                              headerStyle: HeaderStyle(
                                formatButtonVisible: true, // Show format button
                                formatButtonShowsNext: false,
                                formatButtonDecoration: BoxDecoration(
                                  color: startColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                formatButtonTextStyle: GoogleFonts.poppins(
                                  color: endColor,
                                  fontSize: screenWidth * 0.04,
                                ),
                                titleCentered: true,
                                titleTextStyle: GoogleFonts.poppins(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.bold,
                                  color: endColor,
                                ),
                                leftChevronIcon: Icon(Icons.chevron_left, color: endColor),
                                rightChevronIcon: Icon(Icons.chevron_right, color: endColor),
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
                              color: Colors.black87,
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
                              bool isCompleted =
                                  _selectedDayLogs[index][DB_helper.colum_status] == 1;

                              return Container(
                                margin: EdgeInsets.symmetric(vertical: screenHeight * 0.005),
                                decoration: BoxDecoration(
                                  color: isCompleted ? startColor.withOpacity(0.1) : Colors.grey[100],
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
                                  contentPadding:
                                  EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                                  title: Text(
                                    habit[DB_helper.colum_name] ?? "Unknown Habit",
                                    style: GoogleFonts.poppins(
                                      fontSize: screenWidth * 0.045,
                                      fontWeight: FontWeight.w500,
                                      color: isCompleted ? startColor : Colors.black87,
                                    ),
                                  ),
                                  trailing: Icon(
                                    isCompleted ? Icons.check_circle_outline : Icons.cancel_outlined,
                                    color: isCompleted ? Colors.green : Colors.red,
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
                                color: Colors.grey[500],
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
      ),
    );
  }
}