import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:habittracker/Screens/AddHabit.dart';
import 'package:habittracker/database/DB_helper.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  DB_helper? dbref;
  List<Map<String , dynamic>> allhabitdata = [];

  @override
  void initState() {
    super.initState();
    dbref = DB_helper.getInstance;
    getdata();

  }

  Future<void> getdata()async{
    allhabitdata =  await dbref!.getdata();
    setState(() {
   });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Habit Tracker"),
      ),
      body: allhabitdata.isNotEmpty ? ListView.builder(
          itemCount: allhabitdata.length,
          itemBuilder: (context , index){
            return ListTile(
              title: Text(allhabitdata[index][DB_helper.colum_name]),
              trailing: Text(allhabitdata[index][DB_helper.colum_iscomplate] == 1 ? "Completed" : "Not Completed"),
            );

      }) : Center(child: Text("No Data Found"),),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
          onPressed: ()async{
          await Navigator.push(context, MaterialPageRoute(builder: (context)=>
          Addhabit()));
          // dbref!.adddata(name: "Take One Cup of Tea", iscomplate: 1);
          // dbref!.adddata(name: "Go For Gym ", iscomplate: 0);
          // dbref!.adddata(name: "Read book daily one hour", iscomplate: 1);
          await getdata();// after add ui

          }),
    );
  }
}
