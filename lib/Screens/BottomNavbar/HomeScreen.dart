import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:habittracker/Screens/BottomNavbar/AddHabit.dart';
import 'package:habittracker/Screens/UserAuth/Login.dart';
import 'package:habittracker/database/DB_helper.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'HabitCategory.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  DB_helper? dbref;
  List<Map<String, dynamic>> allhabitdata = [];
  List<Map<String, dynamic>> todayhabitlog = [];
  String todaydate = DateFormat("yyyy-MM-dd").format(DateTime.now());
  String? username ;

  @override
  void initState() {
    super.initState();
    dbref = DB_helper.getInstance;
    getdata();
    loadusername();
  }

  Future<bool?> _showDeleteConfirmationDialog(String habitName) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete '$habitName'?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // No
              child: Text("No"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Yes
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleHabitCompletion(int index) async {
    bool newStatus = todayhabitlog
        .firstWhere(
          (log) => log[DB_helper.colum_habit_id] == allhabitdata[index][DB_helper.colum_id],
      orElse: () => {DB_helper.colum_status: 0},
    )[DB_helper.colum_status] ==
        0;
    bool success = await dbref!.adddailyhabitlog(
      habitid: allhabitdata[index][DB_helper.colum_id],
      date: todaydate,
      status: newStatus ? 1 : 0,
    );
    if (success) {
      await getdata();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Habit status updated for today")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update habit status")),
      );
    }
  }

  Future<void> getdata() async {
    allhabitdata = await dbref!.getdata();
    todayhabitlog = await dbref!.gethabitlogbydate(todaydate);
    setState(() {});
  }

  Future<bool?> _showLogoutConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Logout"),
          content: Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // No
              child: Text("No"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Yes
              child: Text("Yes"),
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
        MaterialPageRoute(builder: (context) => Login()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Logged out successfully")),
      );
    }
  }

  Future<void> loadusername()async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    username = pref.getString('username');
    print("username : $username");

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Habit Tracker($username)"),
        actions: [
          IconButton(onPressed: logout, icon: Icon(Icons.logout)),
        ],
      ),
      body: allhabitdata.isNotEmpty
          ? ListView.builder(
        itemCount: allhabitdata.length,
        itemBuilder: (context, index) {
          int habitId = allhabitdata[index][DB_helper.colum_id];
          bool isCompletedToday = todayhabitlog.any(
                (log) => log[DB_helper.colum_habit_id] == habitId && log[DB_helper.colum_status] == 1,
          );
          return ListTile(
            leading: Checkbox(
              value: isCompletedToday,
              onChanged: (value) {
                _toggleHabitCompletion(index);
              },
            ),
            title: Text(
              allhabitdata[index][DB_helper.colum_name],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCompletedToday ? "Completed Today" : "Not Completed Today",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Category: ${allhabitdata[index][DB_helper.column_category] ?? 'None'}",
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Addhabit(
                          habitId: allhabitdata[index][DB_helper.colum_id],
                          habitName: allhabitdata[index][DB_helper.colum_name],
                          category: allhabitdata[index][DB_helper.column_category],
                        ),
                      ),
                    );
                    await getdata();
                  },
                  child: Icon(Icons.edit, color: Colors.blue),
                ),
                GestureDetector(
                  onTap: () async {
                    bool? confirm = await _showDeleteConfirmationDialog(
                      allhabitdata[index][DB_helper.colum_name],
                    );
                    if (confirm == true) {
                      bool success = await dbref!.deletehabitdata(
                        id: allhabitdata[index][DB_helper.colum_id],
                      );
                      if (success) {
                        await getdata();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Habit deleted successfully")),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Failed to delete habit")),
                        );
                      }
                    }
                  },
                  child: Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
          );
        },
      )
          : Center(child: Text("No Data Found")),
    );
  }
}