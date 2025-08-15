import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:habittracker/database/DB_helper.dart';

class Addhabit extends StatefulWidget {
  final int? habitId;
  final String? habitName;
  final String? category;

  const Addhabit({super.key, this.habitId, this.habitName, this.category});

  @override
  State<Addhabit> createState() => _AddhabitState();
}

class _AddhabitState extends State<Addhabit> {
  final TextEditingController _habitController = TextEditingController();
  DB_helper? dbref;

  @override
  void initState() {
    super.initState();
    dbref = DB_helper.getInstance;
    if (widget.habitId != null) {
      _habitController.text = widget.habitName ?? '';
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a habit name")),
      );
      return;
    }

    if (widget.category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No category selected")),
      );
      return;
    }

    bool success;
    if (widget.habitId == null) {
      // Add new habit
      success = await dbref!.adddata(
        name: habitName,
        category: widget.category!,
        iscomplate: 0,
      );
    } else {
      // Update existing habit
      success = await dbref!.updatehabitdata(
        id: widget.habitId!,
        name: habitName,
        // category: widget.category!,
        iscomplate: 0,
      );
    }

    if (success) {
      Navigator.popUntil(context, (route) => route.settings.name == '/Homescreen' || route.isFirst);
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
            const Text(
              "Habit Name",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _habitController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter habit name (e.g., Read a book)",
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Category: ${widget.category ?? 'None'}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveHabit,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50), // Full-width button
              ),
              child: Text(
                widget.habitId == null ? "Add Habit" : "Update Habit",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/cupertino.dart';
  // import 'package:flutter/material.dart';
  // import 'package:habittracker/database/DB_helper.dart';
  //
  // class Addhabit extends StatefulWidget {
  //   final int? habitId;
  //   final String? habitName;
  //   final String? category;
  //
  //   const Addhabit({super.key, this.habitId, this.habitName , this.category});
  //
  //   @override
  //   State<Addhabit> createState() => _AddhabitState();
  // }
  //
  // class _AddhabitState extends State<Addhabit> {
  //   final TextEditingController _habitController = TextEditingController();
  //   DB_helper? dbref;
  //   String? selectcategory;
  //
  //   final List<String> categories = [
  //     'Study',
  //     'Fitness',
  //     'Spiritual',
  //     'Mental Health',
  //   ];
  //
  //   @override
  //   void initState() {
  //     super.initState();
  //     dbref = DB_helper.getInstance;
  //     if (widget.habitId != null) {
  //       _habitController.text = widget.habitName ?? '';
  //       selectcategory = widget.category;
  //     }
  //   }
  //
  //   @override
  //   void dispose() {
  //     _habitController.dispose();
  //     super.dispose();
  //   }
  //
  //   Future<void> _saveHabit() async {
  //     String habitName = _habitController.text.trim();
  //     if (habitName.isEmpty) {
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text("Please enter a habit name")));
  //       return;
  //     }
  //
  //     bool success;
  //     if (widget.habitId == null) {
  //       // Add new habit
  //       success = await dbref!.adddata(
  //         name: habitName,
  //         category: selectcategory!,
  //         iscomplate: 0,
  //       );
  //     } else {
  //       // Update existing habit
  //       success = await dbref!.updatehabitdata(
  //         id: widget.habitId!,
  //         name: habitName,
  //         category: selectcategory!,
  //         iscomplate: 0,
  //       );
  //     }
  //
  //     if (success) {
  //       Navigator.pop(context);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             widget.habitId == null
  //                 ? "Habit added successfully"
  //                 : "Habit updated successfully",
  //           ),
  //         ),
  //       );
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             widget.habitId == null
  //                 ? "Failed to add habit"
  //                 : "Failed to update habit",
  //           ),
  //         ),
  //       );
  //     }
  //   }
  //
  //   @override
  //   Widget build(BuildContext context) {
  //     return Scaffold(
  //       appBar: AppBar(
  //         title: Text(widget.habitId == null ? "Add Habit" : "Edit Habit"),
  //       ),
  //       body: Padding(
  //         padding: const EdgeInsets.all(16.0),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               "Habit Name",
  //               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //             ),
  //             SizedBox(height: 8),
  //             TextField(
  //               controller: _habitController,
  //               decoration: InputDecoration(
  //                 border: OutlineInputBorder(),
  //                 hintText: "Enter habit name (e.g., Read a book)",
  //               ),
  //             ),
  //             SizedBox(height: 16),
  //             Text(
  //               "Category",
  //               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //             ),
  //             SizedBox(height: 8),
  //             DropdownButtonFormField<String>(
  //               value: selectcategory,
  //               decoration: InputDecoration(
  //                 border: OutlineInputBorder(),
  //                 hintText: "Select a category",
  //               ),
  //               items: categories.map((String category) {
  //                 return DropdownMenuItem<String>(
  //                   value: category,
  //                   child: Text(category),
  //                 );
  //               }).toList(),
  //               onChanged: (String? newValue) {
  //                 setState(() {
  //                   selectcategory = newValue;
  //                 });
  //               },
  //             ),
  //             SizedBox(height: 16),
  //             ElevatedButton(
  //               onPressed: _saveHabit,
  //               child: Text(
  //                 widget.habitId == null ? "Add Habit" : "Update Habit",
  //               ),
  //               style: ElevatedButton.styleFrom(
  //                 minimumSize: Size(double.infinity, 50), // Full-width button
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   }
  // }
