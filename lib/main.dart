import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:habittracker/NotificationService.dart';
import 'package:habittracker/Screens/Splashscreen.dart';
import 'package:habittracker/theme_provider.dart';
import 'package:provider/provider.dart';

// final navigatorkey = GlobalKey<NavigatorState>(); // for navigation

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FlutterNotification().initNotification(); // for notification
  print("Firebase Connection Done...");
  runApp(HabitTrackerApp());
}

class HabitTrackerApp extends StatelessWidget {
  HabitTrackerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (_)=> ThemeProvider(),
    child: Consumer<ThemeProvider>(builder: (context , themeprovider , child){
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Habit Tracker',
        themeMode: themeprovider.themeMode,
        theme: ThemeProvider.lighttheme,
        darkTheme: ThemeProvider.darktheme,
        // navigatorKey: navigatorkey,
        home: Splashscreen(),
      );
    }
    )
    );
  }
}
