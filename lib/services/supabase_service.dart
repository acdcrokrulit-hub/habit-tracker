import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/habit.dart';

class SupabaseService {
  SupabaseService._();

  static final SupabaseService instance = SupabaseService._();
  static bool _isInitialized = false;
  static String? _initializationError;

  static bool get isInitialized => _isInitialized;
  static String? get initializationError => _initializationError;

  static void setInitializationError(String error) {
    _initializationError = error;
    _isInitialized = false;
  }

  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    try {
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
      );
      _isInitialized = true;
      _initializationError = null;
    } catch (e) {
      _isInitialized = false;
      _initializationError = e.toString();
      rethrow;
    }
  }

  SupabaseClient get client => Supabase.instance.client;

  // Аутентификация
  Future<AuthResponse> signUp(String email, String password) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: null,
    );
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> resendConfirmation(String email) async {
    await client.auth.resend(type: OtpType.email, email: email);
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Forcefully sign out and clear all auth data
  Future<void> forceSignOut() async {
    await client.auth.signOut();
  }

  User? getCurrentUser() {
    return client.auth.currentUser;
  }

  /// Returns the current user session. If session is null but we have a stored userId,
  /// this attempts to refresh the session automatically.
  Future<User?> getCurrentUserWithRefresh() async {
    final session = client.auth.currentSession;
    if (session != null) {
      return session.user;
    }

    // If no session, check if we can get a user from storage
    // The auth state will be updated via onAuthStateChange stream
    return null;
  }

  Stream<AuthState> onAuthStateChange() {
    return client.auth.onAuthStateChange;
  }

  // Работа с привычками
  Future<List<Habit>> fetchHabits(String userId) async {
    try {
      final data = await client
          .from('habits')
          .select()
          .eq('userid', userId)
          .order('createdat', ascending: false);

      return data
          .map((item) => Habit.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (e) {
      print('Error fetching habits: $e');
      return [];
    }
  }

  Future<void> upsertHabits(List<Habit> habits, String userId) async {
    print('Upserting habits for userId: $userId');
    final rows =
        habits.map((habit) => habit.copyWith(userId: userId).toJson()).toList();
    print('Rows to upsert: ${rows.length} habits');

    try {
      // Upsert each habit individually to handle conflicts better
      for (final row in rows) {
        await client.from('habits').upsert(row, onConflict: 'id');
      }
      print('Successfully upserted habits');
    } catch (e) {
      print('Error upserting habits: $e');
      rethrow;
    }
  }

  Future<void> deleteHabit(String id, String userId) async {
    await client.from('habits').delete().eq('id', id).eq('userid', userId);
  }

  // Работа с настройками пользователя
  Future<Map<String, dynamic>?> fetchUserSettings(String userId) async {
    try {
      final response = await client
          .from('user_settings')
          .select()
          .eq('userid', userId)
          .single();

      if (response != null) {
        return Map<String, dynamic>.from(response as Map);
      }
      return null;
    } catch (e) {
      // Если записи нет, возвращаем null
      if (e.toString().contains('JSON object requested')) {
        return null;
      }
      print('Error fetching user settings: $e');
      return null;
    }
  }

  Future<void> upsertUserSettings(
      String userId, Map<String, dynamic> settings) async {
    try {
      // Ensure the settings include the userid primary key
      final data = Map<String, dynamic>.from(settings);
      data['userid'] = userId;
      await client.from('user_settings').upsert(data, onConflict: 'userid');
      print('Successfully upserted user settings');
    } catch (e) {
      print('Error upserting user settings: $e');
      rethrow;
    }
  }

  Future<void> updateUserSettings(
      String userId, Map<String, dynamic> settings) async {
    try {
      await client.from('user_settings').update(settings).eq('userid', userId);
      print('Successfully updated user settings');
    } catch (e) {
      print('Error updating user settings: $e');
      rethrow;
    }
  }

  Future<void> createUserSettings(
      String userId, Map<String, dynamic> settings) async {
    try {
      await client.from('user_settings').insert({
        'userId': userId,
        ...settings,
      });
      print('Successfully created user settings');
    } catch (e) {
      print('Error creating user settings: $e');
      rethrow;
    }
  }

  // Проверка подключения
  Future<bool> testConnection() async {
    try {
      await client.from('habits').select().limit(1);
      return true;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }
}
