import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadtheme();
  }

  void toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    await _saveTheme();
  }

  Future<void> _loadtheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool("isDarkTheme") ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', _themeMode == ThemeMode.dark);
  }

  static ThemeData get lighttheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xFF667eea),
      scaffoldBackgroundColor: Colors.white,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF667eea),
        secondary: Color(0xFF764ba2),
        background: Colors.white,
        error: Colors.red,
        surface: Colors.white,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black54),
      ),
      iconTheme: const IconThemeData(
        color: Colors.black54,
      ),
      cardColor: Colors.grey[100],
      dividerColor: Colors.grey[300],
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Colors.green,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: Color(0xFF667eea),
        textTheme: ButtonTextTheme.primary,
      ),
    );
  }

  static ThemeData get darktheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF667eea),
      scaffoldBackgroundColor: Colors.grey[900]!,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xff7a7a7a),
          // 0xFF667eea
        secondary: Color(0xff656565),
        // 0xFF764ba2
        background: Colors.grey,
        error: Colors.redAccent,
        surface: Colors.grey,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black54),
        bodyMedium: TextStyle(color: Colors.white54),
      ),
      iconTheme: const IconThemeData(color: Colors.white70),
      cardColor: Colors.grey[800],
      dividerColor: Colors.grey[700],
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Colors.green,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: Color(0xFF667eea),
        textTheme: ButtonTextTheme.primary,
      ),
    );
  }
}