// ignore_for_file: unused_local_variable

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DB_helper {
  DB_helper._(); // private constructor

  static final DB_helper getInstance = DB_helper._(); // singleton instance

  // Table and column names for myhabit
  static final table_name = "myhabit";
  static final colum_id = "id";
  static final colum_name = "Habitname";
  static final colum_iscomplate = "iscomplete";
  static final column_category = "category";
  static final foreign_key_user_id = "user_id";

  // Table and column names for habit_log
  static final table_habit_log = "habit_log";
  static final colum_habit_id = "habit_id";
  static final colum_date = "date";
  static final colum_status = "status";

  // Table and column names for myuser
  static final table_user = "myuser";
  static final column_password = "password";
  static final colum_email = "email";
  static final column_username = 'username';
  static final column_user_id = "user_id";

  Database? mydatabase;

  Future<Database> getDB() async {
    if (mydatabase != null) {
      return mydatabase!;
    } else {
      mydatabase = await openDB();
      return mydatabase!;
    }
  }

  Future<Database> openDB() async {
    Directory appdr = await getApplicationDocumentsDirectory();
    String dbpath = join(appdr.path, "mydatabase.db");

    return await openDatabase(
      dbpath,
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE $table_user($column_user_id INTEGER PRIMARY KEY AUTOINCREMENT, "
              "$column_username TEXT, $colum_email TEXT UNIQUE, $column_password TEXT)",
        );

        await db.execute(
          "CREATE TABLE $table_name($colum_id INTEGER PRIMARY KEY AUTOINCREMENT, "
              "$colum_name TEXT, $column_category TEXT, $colum_iscomplate INTEGER, "
              "$foreign_key_user_id INTEGER, FOREIGN KEY ($foreign_key_user_id) REFERENCES $table_user($column_user_id))",
        );

        await db.execute(
          "CREATE TABLE $table_habit_log($colum_id INTEGER PRIMARY KEY AUTOINCREMENT, "
              "$colum_habit_id INTEGER, $colum_date TEXT, $colum_status INTEGER, "
              "FOREIGN KEY ($colum_habit_id) REFERENCES $table_name($colum_id))",
        );
      },
      version: 6,
      onUpgrade: (db, oldversion, newversion) async {
        if (oldversion < 2) {
          await db.execute(
            "CREATE TABLE $table_user($colum_email TEXT UNIQUE, $column_password TEXT)",
          );
        }
        if (oldversion < 3) {
          await db.execute(
            "CREATE TABLE $table_habit_log($colum_id INTEGER PRIMARY KEY AUTOINCREMENT, "
                "$colum_habit_id INTEGER, $colum_date TEXT, $colum_status INTEGER, "
                "FOREIGN KEY ($colum_habit_id) REFERENCES $table_name($colum_id))",
          );
        }
        if (oldversion < 4) {
          await db.execute("ALTER TABLE $table_name ADD $column_category TEXT");
        }
        if (oldversion < 5) {
          await db.execute("ALTER TABLE $table_user ADD $column_username TEXT");
        }
        if (oldversion < 6) {
          await db.execute("ALTER TABLE $table_user ADD $column_user_id INTEGER");
          await db.execute(
            'UPDATE $table_user SET $column_user_id = (SELECT COUNT(*) FROM $table_user AS t2 WHERE t2.rowid <= $table_user.rowid)',
          );
          await db.execute("ALTER TABLE $table_name ADD $foreign_key_user_id INTEGER");
          await db.execute("UPDATE $table_name SET $foreign_key_user_id = 1 WHERE $foreign_key_user_id IS NULL");
        }
      },
    );
  }

  Future<bool> adddata({
    required int userId,
    required String name,
    required String category,
    required int iscomplate,
  }) async {
    try {
      var db = await getDB();
      int rowaffect = await db.insert(table_name, {
        colum_name: name,
        column_category: category,
        colum_iscomplate: iscomplate,
        foreign_key_user_id: userId,
      });
      return rowaffect > 0;
    } catch (e) {
      print("Add Data Error: $e");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getdata(int userid) async {
    try {
      var db = await getDB();
      List<Map<String, dynamic>> data = await db.query(
        table_name,
        where: "$foreign_key_user_id = ?",
        whereArgs: [userid],
      );
      return data;
    } catch (e) {
      print("Get Data Error: $e");
      return [];
    }
  }

  Future<bool> updatehabitdata({
    required int id,
    required int userid,
    required String name,
    required int iscomplate,
  }) async {
    try {
      var db = await getDB();
      int rowaffect = await db.update(
        table_name,
        {colum_name: name, colum_iscomplate: iscomplate},
        where: '$colum_id = ? AND $foreign_key_user_id = ?',
        whereArgs: [id, userid],
      );
      return rowaffect > 0;
    } catch (e) {
      print("Update Error: $e");
      return false;
    }
  }

  Future<bool> deletehabitdata({required int id, required int userid}) async {
    try {
      var db = await getDB();
      await db.delete(
        table_habit_log,
        where: '$colum_habit_id = ?',
        whereArgs: [id],
      );
      int rowAffect = await db.delete(
        table_name,
        where: '$colum_id = ? AND $foreign_key_user_id = ?',
        whereArgs: [id, userid],
      );
      return rowAffect > 0;
    } catch (e) {
      print("Delete Error: $e");
      return false;
    }
  }

  Future<bool> adddailyhabitlog({
    required int habitid,
    required String date,
    required int status,
  }) async {
    try {
      var db = await getDB();
      var existingLog = await db.query(
        table_habit_log,
        where: '$colum_habit_id = ? AND $colum_date = ?',
        whereArgs: [habitid, date],
      );
      if (existingLog.isNotEmpty) {
        int rowAffect = await db.update(
          table_habit_log,
          {colum_status: status},
          where: '$colum_habit_id = ? AND $colum_date = ?',
          whereArgs: [habitid, date],
        );
        return rowAffect > 0;
      } else {
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

  Future<List<Map<String, dynamic>>> gethabitlogbydate(String date, int userid) async {
    try {
      var db = await getDB();
      return await db.rawQuery(
        'SELECT hl.* FROM $table_habit_log hl '
            'INNER JOIN $table_name h ON hl.$colum_habit_id = h.$colum_id '
            'WHERE hl.$colum_date = ? AND h.$foreign_key_user_id = ?',
        [date, userid],
      );
    } catch (e) {
      print("Get Habit Logs by date Error: $e");
      return [];
    }
  }

  Future<int> adduser({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      var db = await getDB();
      int rowaffect = await db.insert(table_user, {
        column_username: username,
        colum_email: email,
        column_password: password,
      });
      if (rowaffect > 0) {
        var result = await db.rawQuery('SELECT last_insert_rowid() as id');
        return result.first['id'] as int;
      }
      return -1;
    } catch (e) {
      print("Add User Error: $e");
      return -1;
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
      print("Get User Error: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getCategories(int userid) async {
    try {
      var db = await getDB();
      List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT DISTINCT $column_category AS name FROM $table_name WHERE $column_category IS NOT NULL AND $foreign_key_user_id = ?',
        [userid],
      );

      const Map<String, IconData> categoryIcons = {
        'Study': Icons.book,
        'Fitness': Icons.fitness_center,
        'Spiritual': Icons.self_improvement,
        'Mental Health': Icons.psychology,
      };

      Set<String> dbCategories = result.map((category) => category['name'] as String).toSet();

      List<Map<String, dynamic>> categories = categoryIcons.entries.map((entry) {
        return {'name': entry.key, 'icon': entry.value};
      }).toList();

      for (var category in result) {
        String categoryName = category['name'] as String;
        if (!categoryIcons.containsKey(categoryName)) {
          categories.add({
            'name': categoryName,
            'icon': Icons.category,
          });
        }
      }

      return categories;
    } catch (e) {
      print("Get Categories Error: $e");
      return [
        {'name': 'Study', 'icon': Icons.book},
        {'name': 'Fitness', 'icon': Icons.fitness_center},
        {'name': 'Spiritual', 'icon': Icons.self_improvement},
        {'name': 'Mental Health', 'icon': Icons.psychology},
      ];
    }
  }

  Future<int> getcurrentstreak(int userid) async {
    try {
      var db = await getDB();
      DateTime now = DateTime.now();
      int streak = 0;

      while (true) {
        String currentDate = DateFormat('yyyy-MM-dd').format(now);
        List<Map<String, dynamic>> logs = await db.rawQuery(
          'SELECT hl.* FROM $table_habit_log hl '
              'INNER JOIN $table_name h ON hl.$colum_habit_id = h.$colum_id '
              'WHERE hl.$colum_date = ? AND hl.$colum_status = ? AND h.$foreign_key_user_id = ?',
          [currentDate, 1, userid],
        );

        bool hasCompletedHabit = logs.isNotEmpty;

        if (!hasCompletedHabit) {
          break;
        }

        streak++;
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

  Future<int> getlongeststreak(int userid) async {
    try {
      var db = await getDB();
      List<Map<String, dynamic>> logs = await db.rawQuery(
        'SELECT hl.$colum_date FROM $table_habit_log hl '
            'INNER JOIN $table_name h ON hl.$colum_habit_id = h.$colum_id '
            'WHERE hl.$colum_status = ? AND h.$foreign_key_user_id = ? '
            'ORDER BY hl.$colum_date ASC',
        [1, userid],
      );
      if (logs.isEmpty) return 0;
      int currentstrak = 1;
      int longeststreak = 1;

      DateTime? prevDate = DateTime.tryParse(logs.first[colum_date]);

      Set<DateTime> uniqueCompletedDates = logs.map((log) => DateTime.parse(log[colum_date])).toSet();
      List<DateTime> completedDates = uniqueCompletedDates.toList()..sort();

      for (int i = 1; i < completedDates.length; i++) {
        DateTime logDate = completedDates[i];
        if (_isConsecutive(prevDate!, logDate)) {
          currentstrak++;
        } else {
          currentstrak = 1;
        }
        longeststreak = currentstrak > longeststreak ? currentstrak : longeststreak;
        prevDate = logDate;
      }
      return longeststreak;
    } catch (e) {
      print("Get longest streak error: $e");
      return 0;
    }
  }
}