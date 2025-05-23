import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ Firebase Authentication
import 'package:google_sign_in/google_sign_in.dart'; // ✅ Google Sign-In
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart'; // ✅ Facebook Auth
import 'signup_page.dart';
import 'otp_page.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController phoneController = TextEditingController();

    // ✅ Function to verify Phone Number & Send OTP
    void _verifyPhoneNumber() async {
      if (phoneController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter a valid phone number")));
        return;
      }

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneController.text.trim(),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => OtpPage(verificationId: credential.verificationId ?? '')),
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? "Verification Failed")));
        },
        codeSent: (String verificationId, int? resendToken) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => OtpPage(verificationId: verificationId)),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    }

    // ✅ Google Authentication
    Future<void> _signInWithGoogle() async {
      try {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return;

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await FirebaseAuth.instance.signInWithCredential(credential);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OtpPage(verificationId: 'GOOGLE_AUTH')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Google login failed: $e")));
      }
    }

    // ✅ Facebook Authentication
    Future<void> _signInWithFacebook() async {
      try {
        final LoginResult result = await FacebookAuth.instance.login();
        if (result.status == LoginStatus.success) {
          final credential = FacebookAuthProvider.credential(result.accessToken!.token);
          await FirebaseAuth.instance.signInWithCredential(credential);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OtpPage(verificationId: 'FACEBOOK_AUTH')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Facebook login failed: $e")));
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/login_background.png',
              fit: BoxFit.cover,
            ),
          ),

          // Overlay for readability
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.4),
            ),
          ),

          // Login Form Content
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // BIOCONNECT Title
                  const Text(
                    "BIOCONNECT",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 24),

                  // Phone Number Input
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Enter Phone Number",
                      labelStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.3),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Get OTP Button
                  ElevatedButton(
                    onPressed: _verifyPhoneNumber, // ✅ Calls Firebase OTP function
                    child: const Text("Get OTP"),
                  ),
                  const SizedBox(height: 24),

                  // Social Login Options
                  const Text("Or", style: TextStyle(fontSize: 16, color: Colors.white)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.g_mobiledata, size: 40, color: Colors.red),
                        onPressed: _signInWithGoogle, // ✅ Google Authentication
                      ),
                      IconButton(
                        icon: const Icon(Icons.facebook, size: 40, color: Colors.blue),
                        onPressed: _signInWithFacebook, // ✅ Facebook Authentication
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Signup Redirect
                  const Text("Didn't have an account?", style: TextStyle(fontSize: 16, color: Colors.white)),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupPage()));
                    },
                    child: const Text("Sign Up", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
