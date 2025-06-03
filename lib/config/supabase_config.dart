import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SupabaseAuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Check if user is signed in
  bool get isSignedIn => currentUser != null;

  // Sign in with OTP
  Future<AuthResponse> signInWithOTP(String phone) async {
    try {
      final response = await _supabase.auth.signInWithOtp(
        phone: phone,
        channel: OtpChannel.sms,
      );
      return response;
    } catch (e) {
      print('Error sending OTP: $e');
      rethrow;
    }
  }

  // Verify OTP
  Future<AuthResponse> verifyOTP({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        phone: phone,
        token: otp,
        type: OtpType.sms,
      );

      if (response.user != null) {
        // Save login state
        await _saveLoginState(true);
      }

      return response;
    } catch (e) {
      print('Error verifying OTP: $e');
      rethrow;
    }
  }

  // Save user profile to Supabase database
  Future<void> saveUserProfile({
    required String name,
    required int age,
    required String gender,
    required String phone,
  }) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No authenticated user');

      await _supabase.from('user_profiles').upsert({
        'id': user.id,
        'name': name,
        'age': age,
        'gender': gender,
        'phone': phone,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Also save locally
      await _saveUserDataLocally(name, age, gender, phone);
    } catch (e) {
      print('Error saving user profile: $e');
      rethrow;
    }
  }

  // Get user profile from Supabase
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .single();

      return response;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      await _saveLoginState(false);
      await _clearUserData();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Save login state locally
  Future<void> _saveLoginState(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', isLoggedIn);
  }

  // Check login state locally
  Future<bool> isLoggedInLocally() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  // Save user data locally
  Future<void> _saveUserDataLocally(
      String name,
      int age,
      String gender,
      String phone,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setInt('user_age', age);
    await prefs.setString('user_gender', gender);
    await prefs.setString('user_phone', phone);
  }

  // Get user data locally
  Future<Map<String, dynamic>?> getUserDataLocally() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('user_name')) return null;

    return {
      'name': prefs.getString('user_name'),
      'age': prefs.getInt('user_age'),
      'gender': prefs.getString('user_gender'),
      'phone': prefs.getString('user_phone'),
    };
  }

  // Clear user data locally
  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');
    await prefs.remove('user_age');
    await prefs.remove('user_gender');
    await prefs.remove('user_phone');
  }

  // Format phone number for international format
  String formatPhoneNumber(String phone) {
    // Remove any spaces, dashes, or other characters
    phone = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // If it doesn't start with +, add +91 for India
    if (!phone.startsWith('+')) {
      if (phone.startsWith('91')) {
        phone = '+$phone';
      } else {
        phone = '+91$phone';
      }
    }

    return phone;
  }

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}