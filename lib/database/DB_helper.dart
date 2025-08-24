// ignore_for_file: unused_local_variable

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DB_helper {
  DB_helper._(); // private constructor

  static final DB_helper getInstance = DB_helper._(); // class ka object
  //for table my habit
  static final table_name = "myhabit";
  static final colum_id = "id";
  static final colum_name = "Habitname";
  static final colum_iscomplate = "iscomplete";
  static final column_category =
      "category"; // add new column after table create

  //for table habit log
  static final table_habit_log = "habit_log";
  static final colum_habit_id = "habit_id"; // Foreign key to myhabit
  static final colum_date = "date"; // Date of the log
  static final colum_status = "status"; // Completion status for the day

  //for user
  static final table_user = "myuser";
  static final colum_password = "password";
  static final colum_email = "email";
  static final column_username = 'username';

  Database? mydatabase; //  sqlite database object(database ka khud ka object)

  // open database (path check -> if exist then open else create new database)

  // when app load first timr it will crate database and rest of time open
  Future<Database> getDB() async {
    if (mydatabase != null) {
      return mydatabase!; // create new database
    } else {
      mydatabase = await openDB();
      return mydatabase!;
    }
  }

  Future<Database> openDB() async {
    Directory appdr = await getApplicationDocumentsDirectory(); // app direcory
    String dbpath = join(
      appdr.path,
      "mydatabase.db",
    ); // database directory path

    return await openDatabase(
      dbpath,
      onCreate: (db, version) {
        //create habit table
        db.execute(
          "create table $table_name ($colum_id integer primary key autoincrement, "
          "$colum_name text , $column_category text , $colum_iscomplate integer)",
        );

        //user table
        db.execute(
          "create table $table_user ($column_username text ,$colum_email text unique,"
          "$colum_password text)",
        );

        //habit log table
        db.execute(
          "create table $table_habit_log ($colum_id integer primary key autoincrement,"
          "$colum_habit_id integer , $colum_date text , $colum_status integer,"
          "FOREIGN KEY ($colum_habit_id) REFERENCES $table_name($colum_id)",
        );
      },
      version: 5,
      onUpgrade: (db, oldversion, newversion) async {
        if (oldversion < 2) {
          await db.execute(
            "create table $table_user ($colum_email text unique,"
            "$colum_password text)",
          );
        }
        if (oldversion < 3) {
          await db.execute(
            "CREATE TABLE $table_habit_log ($colum_id INTEGER PRIMARY KEY AUTOINCREMENT, "
            "$colum_habit_id INTEGER, $colum_date TEXT, $colum_status INTEGER, "
            "FOREIGN KEY ($colum_habit_id) REFERENCES $table_name($colum_id))",
          );
        }
        if (oldversion < 4) {
          // Add category column to existing myhabit table
          await db.execute("ALTER TABLE $table_name ADD $column_category TEXT");
        }
        if (oldversion < 5) {
          // add username column to existing myuser table
          await db.execute('ALTER TABLE $table_user ADD $column_username text');
        }
      },
    ); // version 1 means database version when we add new
    // table or add new column in table then we change version (for that case version is necessary)
  }

  // after database operation (insert , update , delete)
  // when database execute query it return row affected (how many row affected)

  //add data to database (insert)
  Future<bool> adddata({
    required String name,
    required String category,
    required int iscomplate,
  }) async {
    try {
      var db = await getDB();
      int rowaffect = await db.insert(table_name, {
        colum_name: name,
        column_category: category, // add category
        colum_iscomplate: iscomplate,
      });
      return rowaffect > 0;
    } catch (e) {
      print("Add Data Error : $e");
      return false;
    }
  }

  //  fetch all data
  Future<List<Map<String, dynamic>>> getdata() async {
    try {
      var db = await getDB();
      List<Map<String, dynamic>> data = await db.query(table_name);

      return data;
    } catch (e) {
      print("Error : $e");
      return [];
    }
  }

  //update habit data
  Future<bool> updatehabitdata({
    required int id,
    required String name,
    // required String category,
    required int iscomplate,
  }) async {
    try {
      var db = await getDB();
      int rowaffect = await db.update(table_name, {
        colum_name: name,
        colum_iscomplate: iscomplate,
      }, where: '$colum_id = $id');
      return rowaffect > 0;
    } catch (e) {
      print("Update Error : $e");
      return false;
    }
  }

  //delete data
  Future<bool> deletehabitdata({required int id}) async {
    try {
      var db = await getDB();
      await db.delete(
        table_habit_log,
        where: '$colum_habit_id = ?',
        whereArgs: [id],
      );
      int rowAffect = await db.delete(
        table_name,
        where: '$colum_id = ?',
        whereArgs: [id],
      );
      return rowAffect > 0;
    } catch (e) {
      print("Delete Error : $e");
      return false;
    }
  }

  //add daily habit logs
  Future<bool> adddailyhabitlog({
    required int habitid,
    required String date,
    required int status,
  }) async {
    try {
      var db = await getDB();
      // Check if log exists for the habit and date
      var existingLog = await db.query(
        table_habit_log,
        where: '$colum_habit_id = ? AND $colum_date = ?',
        whereArgs: [habitid, date],
      );
      if (existingLog.isNotEmpty) {
        // Update existing log
        int rowAffect = await db.update(
          table_habit_log,
          {colum_status: status},
          where: '$colum_habit_id = ? AND $colum_date = ?',
          whereArgs: [habitid, date],
        );
        return rowAffect > 0;
      } else {
        // Insert new log
        int rowAffect = await db.insert(table_habit_log, {
          colum_habit_id: habitid,
          colum_date: date,
          colum_status: status,
        });
        return rowAffect > 0;
      }
    } catch (e) {
      print("Add Habit Log Error: $e");
      return false;
    }
  }

  // Fetch habit logs for a specific habit
  Future<List<Map<String, dynamic>>> gethabitlog(int habitid) async {
    try {
      var db = await getDB();
      return await db.query(
        table_habit_log,
        where: '$colum_habit_id = ?',
        whereArgs: [habitid],
      );
    } catch (e) {
      print("Get Habit Logs Error: $e");
      return [];
    }
  }

  //fetch habit log for specific date

  Future<List<Map<String, dynamic>>> gethabitlogbydate(String date) async {
    try {
      var db = await getDB();
      return await db.query(
        table_habit_log,
        where: '$colum_date = ?',
        whereArgs: [date],
      );
    } catch (e) {
      print("Get Habit Logs by date Error: $e");
      return [];
    }
  }

  //Add new user
  Future<bool> adduser({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      var db = await getDB();
      int rowaffect = await db.insert(table_user, {
        column_username: username,
        colum_email: email,
        colum_password: password,
      });
      return rowaffect > 0;
    } catch (e) {
      print("Add User Error : $e");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getuser(String email) async {
    try {
      var db = await getDB();
      List<Map<String, dynamic>> data = await db.query(
        table_user,
        where: "$colum_email = ?",
        whereArgs: [email],
      );
      return data;
    } catch (e) {
      print("Error : $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      var db = await getDB();
      // Fetch distinct categories from the myhabit table
      List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT DISTINCT $column_category AS name FROM $table_name WHERE $column_category IS NOT NULL',
      );

      // Define default categories with icons
      const Map<String, IconData> categoryIcons = {
        'Study': Icons.book,
        'Fitness': Icons.fitness_center,
        'Spiritual': Icons.self_improvement,
        'Mental Health': Icons.psychology,
      };

      // Convert database results to a set of category names
      Set<String> dbCategories =
          result.map((category) => category['name'] as String).toSet();

      // Create a list of categories, starting with default categories
      List<Map<String, dynamic>> categories =
          categoryIcons.entries.map((entry) {
            return {'name': entry.key, 'icon': entry.value};
          }).toList();

      // Add any additional categories from the database that aren't in the default list
      for (var category in result) {
        String categoryName = category['name'] as String;
        if (!categoryIcons.containsKey(categoryName)) {
          categories.add({
            'name': categoryName,
            'icon': Icons.category, // Fallback icon for custom categories
          });
        }
      }

      return categories;
    } catch (e) {
      print("Get Categories Error: $e");
      // Return default categories on error
      return [
        {'name': 'Study', 'icon': Icons.book},
        {'name': 'Fitness', 'icon': Icons.fitness_center},
        {'name': 'Spiritual', 'icon': Icons.self_improvement},
        {'name': 'Mental Health', 'icon': Icons.psychology},
      ];
    }
  }

  Future<int> getcurrentstreak() async {
    try {
      var db = await getDB();
      DateTime now = DateTime.now();
      int streak = 0;

      while (true) {
        String currentDate = DateFormat('yyyy-MM-dd').format(now);
        List<Map<String, dynamic>> logs = await db.query(
          table_habit_log,
          where: '$colum_date = ? AND $colum_status = ?',
          whereArgs: [currentDate, 1],
        );

        bool hasCompletedHabit = logs.isNotEmpty;

        if (!hasCompletedHabit) {
          break; // Break if no habits were completed on this day
        }

        streak++; // Increment streak if at least one habit was completed
        now = now.subtract(const Duration(days: 1));
      }
      return streak;
    } catch (e) {
      print("Get current streak error: $e");
      return 0;
    }
  }

  bool _isConsecutive(DateTime prevDate, DateTime currentDate) {
    return currentDate.difference(prevDate).inDays == 1;
  }

  Future<int> getlongeststreak() async {
    try {
      var db = await getDB();
      List<Map<String, dynamic>> logs = await db.query(
        table_habit_log,
        where: '$colum_status = ?',
        whereArgs: [1],
        orderBy: '$colum_date ASC',
      );
      if (logs.isEmpty) return 0;
      int currentstrak = 0;
      int longeststreak = 0;

      DateTime? prevDate;

      // Group logs by date to check if any habit was completed on each day
      Map<String, List<Map<String, dynamic>>> logsByDate = {};
      for (var log in logs) {
        String date = log[colum_date];
        if (!logsByDate.containsKey(date)) {
          logsByDate[date] = [];
        }
        logsByDate[date]!.add(log);
      }
      List<DateTime> completedDates = logsByDate.keys
          .map((date) => DateTime.parse(date))
          .toList()
        ..sort((a, b) => a.compareTo(b));

      for (var logDate in completedDates) {
        if (prevDate == null || _isConsecutive(prevDate!, logDate)) {
          currentstrak++;
        } else {
          currentstrak = 1; // Reset streak if not consecutive
        }
        longeststreak = currentstrak > longeststreak ? currentstrak : longeststreak;
        prevDate = logDate;
      }
      return longeststreak;
    } catch (e) {
      print("get current streak error");
      return 0;
    }
  }
}
