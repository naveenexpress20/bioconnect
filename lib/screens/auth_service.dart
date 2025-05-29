import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient supabase = Supabase.instance.client;

  // ✅ Send OTP via Phone
  Future<void> sendOtp(String phoneNumber) async {
    final response = await supabase.auth.signInWithOtp(phone: phoneNumber);
    if (response.error != null) {
      print("Error: ${response.error!.message}");
    } else {
      print("OTP sent successfully!");
    }
  }

  // ✅ Verify OTP
  Future<void> verifyOtp(String phoneNumber, String otpCode) async {
    final response = await supabase.auth.verifyOtp(
      phone: phoneNumber,
      token: otpCode,
    );

    if (response.error != null) {
      print("OTP Verification Failed: ${response.error!.message}");
    } else {
      print("OTP Verification Successful!");
    }
  }

  // ✅ Email Sign-In
  Future<void> signInWithEmail(String email, String password) async {
    final response = await supabase.auth.signInWithPassword(email: email, password: password);
    if (response.error != null) {
      print("Email Login Failed: ${response.error!.message}");
    } else {
      print("Email Login Successful!");
    }
  }

  // ✅ Email Sign-Up
  Future<void> signUpWithEmail(String email, String password) async {
    final response = await supabase.auth.signUp(email: email, password: password);
    if (response.error != null) {
      print("Sign-up Failed: ${response.error!.message}");
    } else {
      print("Sign-up Successful! Verify your email.");
    }
  }

  // ✅ Google Sign-In
  Future<void> signInWithGoogle() async {
    final response = await supabase.auth.signInWithOAuth(Provider.google);
    if (response.error != null) {
      print("Google Auth Failed: ${response.error!.message}");
    } else {
      print("Google Login Successful!");
    }
  }

  // ✅ Facebook Sign-In
  Future<void> signInWithFacebook() async {
    final response = await supabase.auth.signInWithOAuth(Provider.facebook);
    if (response.error != null) {
      print("Facebook Auth Failed: ${response.error!.message}");
    } else {
      print("Facebook Login Successful!");
    }
  }
}
