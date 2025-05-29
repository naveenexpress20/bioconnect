import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient supabase = Supabase.instance.client;

  // ✅ Stream for Auth State Changes
  Stream<AuthState> get authStateChanges => supabase.auth.onAuthStateChange;

  // ✅ Send OTP via Phone
  Future<void> sendOtp(String phoneNumber) async {
    try {
      await supabase.auth.signInWithOtp(phone: phoneNumber);
      print("OTP sent successfully!");
    } catch (e) {
      print("OTP Send Error: $e");
    }
  }

  // ✅ Verify OTP
  Future<void> verifyOtp(String phoneNumber, String otpCode) async {
    try {
      await supabase.auth.verifyOTP(
        phone: phoneNumber,
        token: otpCode,
        type: OtpType.sms,
      );
      print("OTP Verification Successful!");
    } catch (e) {
      print("OTP Verification Failed: $e");
    }
  }

  // ✅ Email Sign-In
  Future<void> signInWithEmail(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        print("Email Login Failed: No user returned.");
      } else {
        print("Email Login Successful!");
      }
    } catch (e) {
      print("Email Login Error: $e");
    }
  }

  // ✅ Email Sign-Up
  Future<void> signUpWithEmail(String email, String password, Map<String, dynamic> userData) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: userData,
      );
      if (response.user == null) {
        print("Sign-up Failed: No user returned.");
      } else {
        print("Sign-up Successful! Verify your email.");
      }
    } catch (e) {
      print("Sign-up Error: $e");
    }
  }


  // ✅ Google Sign-In
  Future<void> signInWithGoogle() async {
    try {
      await supabase.auth.signInWithOAuth(OAuthProvider.google);
      print("Google Login Initiated.");
    } catch (e) {
      print("Google Auth Error: $e");
    }
  }

  // ✅ Facebook Sign-In
  Future<void> signInWithFacebook() async {
    try {
      await supabase.auth.signInWithOAuth(OAuthProvider.facebook);
      print("Facebook Login Initiated.");
    } catch (e) {
      print("Facebook Auth Error: $e");
    }
  }

  // ✅ Sign Out
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
      print("User signed out.");
    } catch (e) {
      print("Sign out error: $e");
    }
  }

  // ✅ Get Current User
  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }
}
