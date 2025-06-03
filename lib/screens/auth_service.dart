import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Auth state changes stream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Sign in with email and password (supports both named and positional parameters)
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign up with email and password (supports both named and positional parameters)
  Future<AuthResponse> signUpWithEmail(String email, String password, [Map<String, dynamic>? userData]) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: userData,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Send OTP to phone number
  Future<void> sendOtp(String phoneNumber) async {
    try {
      await _supabase.auth.signInWithOtp(
        phone: phoneNumber,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      final response = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.bioconnect://login-callback/',
      );
      return response;
    } catch (e) {
      print('Google Sign In Error: $e');
      return false;
    }
  }

  // Verify OTP for phone
  Future<AuthResponse> verifyPhoneOTP({
    required String phone,
    required String token,
  }) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        type: OtpType.sms,
        phone: phone,
        token: token,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Verify OTP for email
  Future<AuthResponse> verifyEmailOTP({
    required String email,
    required String token,
  }) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        type: OtpType.signup,
        email: email,
        token: token,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Get user display name
  String? getUserName() {
    final user = currentUser;
    if (user != null) {
      return user.userMetadata?['name'] ??
          user.userMetadata?['full_name'] ??
          user.email?.split('@')[0] ??
          'User';
    }
    return null;
  }

  // Get user email
  String? getUserEmail() {
    final user = currentUser;
    return user?.email;
  }

  // Get user phone
  String? getUserPhone() {
    final user = currentUser;
    return user?.phone;
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return currentUser != null;
  }

  // Get user ID
  String? getUserId() {
    final user = currentUser;
    return user?.id;
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  // Update user data
  Future<UserResponse> updateUser(Map<String, dynamic> userData) async {
    try {
      final response = await _supabase.auth.updateUser(
        UserAttributes(data: userData),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}