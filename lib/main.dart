import 'package:flutter/material.dart';
import 'package:rotalucro/core/themes.dart';
import 'package:rotalucro/presentation/screens/splash_screen.dart';

void main() {
  runApp(const RotaLucroApp());
}

class RotaLucroApp extends StatelessWidget {
  const RotaLucroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RotaLucro',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
