import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/auth_screen.dart';
import 'providers/habit_provider.dart';
import 'providers/navigation_provider.dart';
import 'services/notification_service.dart';
import 'services/supabase_service.dart';
import 'debug_supabase.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  await SupabaseService.initialize(
    url: 'https://djauslrsmnqgfjljmqln.supabase.co',
    anonKey: 'sb_publishable_UlzUd9yG-_x8qnuUN3Xf9w_vI8pX7bZ',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HabitProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: Consumer2<HabitProvider, NavigationProvider>(
        builder: (context, habitProvider, navProvider, _) {
          return MaterialApp(
            title: 'Habit Tracker',
            debugShowCheckedModeBanner: false,
            theme: habitProvider.isDarkTheme ? _darkTheme : _lightTheme,
            home: !habitProvider.initialized
                ? const Scaffold(
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Загрузка...'),
                        ],
                      ),
                    ),
                  )
                : habitProvider.userId != null
                    ? const HomeScreen()
                    : AuthScreen(),
            routes: {
              '/home': (context) => const HomeScreen(),
              '/auth': (context) => AuthScreen(),
              '/debug': (context) => const DebugSupabasePage(),
            },
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
    backgroundColor: Color(0xFF6C63FF),
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
    backgroundColor: Color(0xFF6C63FF),
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
