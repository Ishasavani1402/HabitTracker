import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../database/DB_helper.dart';

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
    return Scaffold(
      appBar: AppBar(title: Text("Habit Calendar")),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            selectedDayPredicate:  (day)=> isSameDay(_selectedDay,  day),
            onDaySelected: (selectedday , focuseday){
              setState(() {
                _selectedDay = selectedday;
                _focusedDay = focuseday;
              });
              _loadSelectedDayLogs();
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          Expanded(child:_selectedDayLogs.isNotEmpty ?
          ListView.builder(
              itemCount:  widget.habits.length,
              itemBuilder: (context , index){
                int habitId = widget.habits[index][DB_helper.colum_id];
                bool isCompleted = _selectedDayLogs.any(
                      (log) => log[DB_helper.colum_habit_id] == habitId && log[DB_helper.colum_status] == 1,
                );
                return ListTile(
                  title: Text(widget.habits[index][DB_helper.colum_name]),
                  trailing: Icon(
                    isCompleted ? Icons.check_circle : Icons.cancel,
                    color: isCompleted ? Colors.green : Colors.red,
                  ),
                );
          }) :
          Center(child: Text("No habit Track found"),))
        ],
      ),
    );
  }
}
