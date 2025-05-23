import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ Firebase Authentication
import 'home_page.dart';
import 'dart:async';

class OtpPage extends StatefulWidget {
  final String verificationId;
  const OtpPage({super.key, required this.verificationId});

  @override
  _OtpPageState createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  late Timer _timer;
  int _timeRemaining = 120; // 120 seconds (2 minutes)
  final TextEditingController _otpController = TextEditingController();
  bool _isNextButtonVisible = false;
  FirebaseAuth auth = FirebaseAuth.instance; // ✅ Firebase Authentication Instance

  @override
  void initState() {
    super.initState();
    _startTimer();

    // Listen for OTP input changes
    _otpController.addListener(() {
      setState(() {
        _isNextButtonVisible = _otpController.text.trim().length == 6;
      });
    });
  }

  void _startTimer() {
    // Cancel existing timer if any
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining == 0) {
        timer.cancel();
      } else {
        setState(() {
          _timeRemaining--;
        });
      }
    });
  }

  // Format seconds to MM:SS
  String get formattedTime {
    int minutes = _timeRemaining ~/ 60;
    int seconds = _timeRemaining % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _timer.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _verifyOtp() async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: _otpController.text.trim(),
      );

      await auth.signInWithCredential(credential); // ✅ Sign in user
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid OTP. Please try again.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("OTP Verification")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Enter the OTP sent to your phone",
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // OTP Input Field
            SizedBox(
              width: 200,
              child: TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6, // ✅ OTP is typically 6 digits
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: "------",
                  counterText: "", // Hide the counter
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Countdown Timer
            Text("Time remaining: $formattedTime", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 12),

            // Resend OTP Button
            TextButton(
              onPressed: _timeRemaining == 0 ? () {
                // TODO: Implement OTP resend logic
                setState(() {
                  _timeRemaining = 120;
                });
                _startTimer();
              } : null,
              child: const Text("Resend OTP"),
            ),
            const SizedBox(height: 24),

            // Next Button (only visible when OTP length is 6)
            Visibility(
              visible: _isNextButtonVisible,
              child: ElevatedButton(
                onPressed: _verifyOtp, // ✅ Calls OTP Verification function
                child: const Text("Verify OTP"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
