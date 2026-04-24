import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://djauslrsmnqgfjljmqln.supabase.co',
    anonKey: 'sb_publishable_UlzUd9yG-_x8qnuUN3Xf9w_vI8pX7bZ',
  );

  print('Supabase initialized');

  // Test connection by fetching session
  final client = Supabase.instance.client;

  try {
    final session = client.auth.currentSession;
    print('Current session: $session');

    // Try to get user
    final user = client.auth.currentUser;
    print('Current user: $user');

    // Try a simple query to test database connection
    // First check if we can access the habits table (will fail if not authenticated)
    try {
      final data = await client.from('habits').select().limit(1);
      print('Habits query result: $data');
    } catch (e) {
      print('Error querying habits table: $e');
      // This is expected if not authenticated
    }
  } catch (e) {
    print('Error: $e');
  }
}
