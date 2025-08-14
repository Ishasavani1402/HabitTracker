  import 'package:flutter/cupertino.dart';
  import 'package:flutter/material.dart';
  import 'package:habittracker/database/DB_helper.dart';

  class Addhabit extends StatefulWidget {
    final int? habitId;
    final String? habitName;
    // final bool? isCompleted;

    const Addhabit({super.key, this.habitId, this.habitName});

    @override
    State<Addhabit> createState() => _AddhabitState();
  }

  class _AddhabitState extends State<Addhabit> {
    final TextEditingController _habitController = TextEditingController();
    // bool _isCompleted = false;
    DB_helper? dbref;

    @override
    void initState() {
      super.initState();
      dbref = DB_helper.getInstance;
      if (widget.habitId != null) {
        _habitController.text = widget.habitName ?? '';
        // _isCompleted = widget.isCompleted ?? false;
      }
    }

    @override
    void dispose() {
      _habitController.dispose();
      super.dispose();
    }

    Future<void> _saveHabit() async {
      String habitName = _habitController.text.trim();
      if (habitName.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Please enter a habit name")));
        return;
      }

      bool success;
      if (widget.habitId == null) {
        // Add new habit
        success = await dbref!.adddata(
          name: habitName,
          iscomplate: 0,
        );
      } else {
        // Update existing habit
        success = await dbref!.updatehabitdata(
          id: widget.habitId!,
          name: habitName,
          iscomplate: 0,
        );
      }

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.habitId == null
                  ? "Habit added successfully"
                  : "Habit updated successfully",
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.habitId == null
                  ? "Failed to add habit"
                  : "Failed to update habit",
            ),
          ),
        );
      }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.habitId == null ? "Add Habit" : "Edit Habit"),
        ),
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
              ElevatedButton(
                onPressed: _saveHabit,
                child: Text(
                  widget.habitId == null ? "Add Habit" : "Update Habit",
                ),
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
