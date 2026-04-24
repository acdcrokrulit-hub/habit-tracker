import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import 'package:habit_tracker/services/supabase_service.dart';

class DebugSupabasePage extends StatefulWidget {
  const DebugSupabasePage({Key? key}) : super(key: key);

  @override
  State<DebugSupabasePage> createState() => _DebugSupabasePageState();
}

class _DebugSupabasePageState extends State<DebugSupabasePage> {
  String _log = '';
  final List<String> _logLines = [];

  void _logMessage(String message) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    final logEntry = '[$timestamp] $message';
    setState(() {
      _logLines.add(logEntry);
      if (_logLines.length > 20) {
        _logLines.removeAt(0);
      }
      _log = _logLines.join('\n');
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeSupabase();
  }

  Future<void> _initializeSupabase() async {
    _logMessage('Initializing Supabase...');
    try {
      await SupabaseService.initialize(
        url: 'https://djauslrsmnqgfjljmqln.supabase.co',
        anonKey: 'sb_publishable_UlzUd9yG-_x8qnuUN3Xf9w_vI8pX7bZ',
      );
      _logMessage('Supabase initialized successfully');

      // Check current session
      final session = Supabase.instance.client.auth.currentSession;
      _logMessage('Current session: $session');

      final user = Supabase.instance.client.auth.currentUser;
      _logMessage('Current user: $user');

      if (user != null) {
        _logMessage('User ID: ${user.id}');
        _logMessage('User email: ${user.email}');
      }
    } catch (e) {
      _logMessage('Error initializing Supabase: $e');
    }
  }

  Future<void> _testSignIn() async {
    _logMessage('Attempting sign in with dev credentials...');
    try {
      final provider = Provider.of<HabitProvider>(context, listen: false);
      await provider.signIn('mukhanovr@icloud.com', 'mukhanov06');
      _logMessage('Sign in successful');

      final userId = provider.userId;
      _logMessage('Provider userId: $userId');

      // Load habits - we'll trigger a reload by calling a public method or accessing habits
      // Since _loadHabits is private, we'll just access the habits getter which might trigger loading
      _logMessage('Habits count: ${provider.habits.length}');
    } catch (e) {
      _logMessage('Sign in failed: $e');
    }
  }

  Future<void> _testAddHabit() async {
    _logMessage('Attempting to add habit...');
    try {
      final provider = Provider.of<HabitProvider>(context, listen: false);
      final userId = provider.userId;
      _logMessage('Current userId in provider: $userId');

      if (userId == null) {
        _logMessage('User ID is null, signing in first...');
        await provider.signIn('mukhanovr@icloud.com', 'mukhanov06');
      }

      await provider.addHabit(
        'Test Habit ${DateTime.now().millisecondsSinceEpoch}',
        'This is a test habit',
      );
      _logMessage('Habit added successfully');
      _logMessage('Habits count: ${provider.habits.length}');
    } catch (e) {
      _logMessage('Error adding habit: $e');
    }
  }

  Future<void> _testFetchHabits() async {
    _logMessage('Attempting to fetch habits from Supabase...');
    try {
      final provider = Provider.of<HabitProvider>(context, listen: false);
      final userId = provider.userId;
      _logMessage('Current userId in provider: $userId');

      if (userId == null) {
        _logMessage('User ID is null, signing in first...');
        await provider.signIn('mukhanovr@icloud.com', 'mukhanov06');
      }

      final habits = await SupabaseService.instance.fetchHabits(userId!);
      _logMessage('Fetched ${habits.length} habits from Supabase');
      for (final habit in habits) {
        _logMessage('Habit: ${habit.title} (id: ${habit.id})');
      }
    } catch (e) {
      _logMessage('Error fetching habits: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase Debug'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                _log,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _testSignIn,
                  child: const Text('Test Sign In'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _testAddHabit,
                  child: const Text('Test Add Habit'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _testFetchHabits,
                  child: const Text('Test Fetch Habits'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
