import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'providers/habit_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HabitProvider(),
      child: Consumer<HabitProvider>(
        builder: (context, provider, _) {
          return MaterialApp(
            title: 'Habit Tracker',
            debugShowCheckedModeBanner: false,
            theme: provider.isDarkTheme ? _darkTheme : _lightTheme,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}

final ThemeData _darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF6C63FF),
  scaffoldBackgroundColor: const Color(0xFF0F0F1A),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF6C63FF),
    secondary: Color(0xFF4ECDC4),
    surface: Color(0xFF1A1A2E),
    background: Color(0xFF0F0F1A),
  ),
  fontFamily: 'Poppins',
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF0F0F1A),
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  cardTheme: CardThemeData(
    color: const Color(0xFF1A1A2E),
    elevation: 8,
    shadowColor: const Color(0xFF6C63FF).withOpacity(0.3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: const Color(0xFF6C63FF),
    foregroundColor: Colors.white,
    elevation: 8,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF1A1A2E),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
  ),
);

final ThemeData _lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFF6C63FF),
  scaffoldBackgroundColor: const Color(0xFFF5F7FA),
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF6C63FF),
    secondary: Color(0xFF4ECDC4),
    surface: Color(0xFFFFFFFF),
    background: Color(0xFFF5F7FA),
  ),
  fontFamily: 'Poppins',
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFFFFFFF),
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: Color(0xFF1A1A2E),
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(color: Color(0xFF1A1A2E)),
  ),
  cardTheme: CardThemeData(
    color: const Color(0xFFFFFFFF),
    elevation: 8,
    shadowColor: const Color(0xFF6C63FF).withOpacity(0.2),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: const Color(0xFF6C63FF),
    foregroundColor: Colors.white,
    elevation: 8,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF0F2F5),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
  ),
);
