import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:habittracker/database/DB_helper.dart';

class Addhabit extends StatefulWidget {
  const Addhabit({super.key});

  @override
  State<Addhabit> createState() => _AddhabitState();
}

class _AddhabitState extends State<Addhabit> {
  final TextEditingController _habitController = TextEditingController();
  bool _isCompleted = false;
  DB_helper? dbref;

  @override
  void initState() {
    super.initState();
    dbref = DB_helper.getInstance;
  }

  @override
  void dispose() {
    _habitController.dispose();
    super.dispose();
  }

  Future<void> _addHabit() async {
    String habitName = _habitController.text.trim();
    if (habitName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please enter a habit name")));
      return;
    }
    bool success = await dbref!.adddata(
      name: habitName,
      iscomplate: _isCompleted ? 1 : 0,
    );
    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to add habit")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Habits")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Habit Name",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _habitController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter habit name (e.g., Read a book)",
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _isCompleted,
                  onChanged: (value) {
                    setState(() {
                      _isCompleted = value ?? false;
                    });
                  },
                ),
                Text("Mark as Completed"),
              ],
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _addHabit,
              child: Text("Add Habit"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50), // Full-width button
              ),
            ),
          ],
        ),
      ),
    );
  }
}
