import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DB_helper {
  DB_helper._(); // private constructor

  static final DB_helper getInstance = DB_helper._(); // class ka object
  static final table_name = "myhabit";
  static final table_user = "myuser";
  static final colum_id = "id";
  static final colum_name = "Habitname";
  static final colum_iscomplate = "iscomplete";
  static final colum_password = "password";
  static final colum_email = "email";

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
        //create table
        db.execute(
          "create table $table_name ($colum_id integer primary key autoincrement, "
          "$colum_name text , $colum_iscomplate integer)",
        );

        db.execute(
          "create table $table_user ($colum_email text unique,"
          "$colum_password text)",
        );
      },
      version: 2,
      onUpgrade: (db , oldversion , newversion)async{
        if(oldversion < 2){
          await db.execute(
            "create table $table_user ($colum_email text unique,"
                "$colum_password text)",
          );
        }

      }
    ); // version 1 means database version when we add new
    // table or add new column in table then we change version (for that case version is necessary)
  }

  // after database operation (insert , update , delete) when database execute query it return row affected (how many row affected)

  //add data to database (insert)
  Future<bool> adddata({required String name, required int iscomplate}) async {
    try{
      var db = await getDB();
      int rowaffect = await db.insert(table_name, {
        colum_name: name,
        colum_iscomplate: iscomplate,
      });
      return rowaffect > 0;
    }catch(e){
      print("Error : $e");
      return false;
    }

  }

  //  fetch all data
  Future<List<Map<String, dynamic>>> getdata() async {
    try{
      var db = await getDB();
      List<Map<String, dynamic>> data = await db.query(table_name);

      return data;
    }catch(e){
      print("Error : $e");
      return [];
    }

  }

  Future<bool> adduser({
    required String email,
    required String password,
  }) async {
    try{
      var db = await getDB();
      int rowaffect = await db.insert(table_user, {
        colum_email: email,
        colum_password: password,
      });
      return rowaffect > 0;
    }catch(e){
      print("Error : $e");
      return false;
    }

  }

  Future<List<Map<String, dynamic>>> getuser(String email) async {
    try{
      var db = await getDB();
      List<Map<String, dynamic>> data = await db.query(
        table_user,
        where: "$colum_email = ?",
        whereArgs: [email],
      );
      return data;
    }catch(e){
      print("Error : $e");
      return [];
    }

  }
}
