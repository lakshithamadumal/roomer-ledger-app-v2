import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;

  Session? get currentSession => _client.auth.currentSession;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Sign In with email & password
  Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign Up with email & password and create a UserProfile
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user != null) {
      // Create user profile in 'profiles' table
      await _client.from('profiles').insert({
        'id': user.id,
        'username': username,
      });
    }
    return response;
  }

  // Fetch a user profile by id
  Future<UserProfile?> fetchProfile(String userId) async {
    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data != null) {
        return UserProfile.fromJson(data);
      }
    } catch (e) {
      print('Error fetching profile: $e');
    }
    return null;
  }

  // Fetch current user's profile
  Future<UserProfile?> fetchCurrentProfile() async {
    final user = currentUser;
    if (user != null) {
      return await fetchProfile(user.id);
    }
    return null;
  }

  // Sign Out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
