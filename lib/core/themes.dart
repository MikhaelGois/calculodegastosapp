import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.teal,
      primaryColor: const Color(0xFF00A8C2), // Azul turquesa
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF00A8C2),
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF00A8C2),
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00A8C2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.teal,
      primaryColor: const Color(0xFF00A8C2),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF00A8C2),
        brightness: Brightness.dark,
      ),
    );
  }
}
