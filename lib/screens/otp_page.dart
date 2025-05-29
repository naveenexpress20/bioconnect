import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class OtpPage extends StatefulWidget {
  final String phoneNumber;
  final String? verificationId; // Kept for compatibility but not used with Supabase
  final Map<String, dynamic>? userData;

  const OtpPage({
    Key? key,
    required this.phoneNumber,
    this.verificationId,
    this.userData,
  }) : super(key: key);

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final auth = Supabase.instance.client.auth; // Updated to use auth directly
  final List<TextEditingController> _otpControllers =
  List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes =
  List.generate(6, (index) => FocusNode());

  bool _isLoading = false;
  bool _isResendEnabled = false;
  int _countdown = 60;
  Timer? _timer;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _isResendEnabled = false;
      _countdown = 60;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        setState(() {
          _isResendEnabled = true;
        });
        timer.cancel();
      }
    });
  }

  String get _formattedCountdown {
    int minutes = _countdown ~/ 60;
    int seconds = _countdown % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _onOTPChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Clear error message when user starts typing
    if (_errorMessage.isNotEmpty) {
      setState(() {
        _errorMessage = '';
      });
    }

    // Auto-submit when all fields are filled
    if (_otpControllers.every((controller) => controller.text.isNotEmpty)) {
      // Add small delay to ensure UI updates
      Future.delayed(const Duration(milliseconds: 100), () {
        _verifyOTP();
      });
    }
  }

  String _getOTPCode() {
    return _otpControllers.map((controller) => controller.text).join();
  }

  // Updated OTP verification method using auth.verifyOtp()
  Future<void> _verifyOTP() async {
    final otpCode = _getOTPCode();
    if (otpCode.length != 6) {
      setState(() {
        _errorMessage = 'Please enter complete OTP';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Verify OTP using auth.verifyOtp()
      final response = await auth.verifyOTP(
        phone: widget.phoneNumber,
        token: otpCode,
        type: OtpType.sms,
      );

      if (mounted) {
        if (response.session != null && response.user != null) {
          // OTP verification successful
          _navigateToHome();
        } else {
          setState(() {
            _errorMessage = 'OTP verification failed. Please try again.';
            _isLoading = false;
          });
          _clearOTP();
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _getErrorMessage(e.message);
          _isLoading = false;
        });
        _clearOTP();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Verification failed. Please try again.';
          _isLoading = false;
        });
        _clearOTP();
      }
    }
  }

  void _navigateToHome() {
    // Get user info from auth session
    final user = auth.currentUser;
    String userName = 'User';

    if (user != null) {
      // Try to get name from user metadata or phone
      userName = user.userMetadata?['full_name'] ??
          user.userMetadata?['name'] ??
          user.phone ??
          'User';
    }

    // Use userData if available, otherwise use auth user info
    if (widget.userData != null) {
      userName = widget.userData!['name'] ??
          widget.userData!['firstName'] ??
          userName;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
          (route) => false,
      arguments: {
        'userName': userName,
        'userData': widget.userData,
        'user': user, // Pass auth user object
      },
    );
  }

  String _getErrorMessage(String errorMessage) {
    // Handle auth-specific error messages
    if (errorMessage.toLowerCase().contains('invalid')) {
      return 'Invalid OTP. Please check and try again.';
    } else if (errorMessage.toLowerCase().contains('expired')) {
      return 'OTP has expired. Please request a new one.';
    } else if (errorMessage.toLowerCase().contains('too many')) {
      return 'Too many attempts. Please try again later.';
    } else if (errorMessage.toLowerCase().contains('token')) {
      return 'Invalid OTP. Please try again.';
    } else {
      return 'Verification failed: $errorMessage';
    }
  }

  void _clearOTP() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    if (_focusNodes.isNotEmpty && _focusNodes[0].canRequestFocus) {
      _focusNodes[0].requestFocus();
    }
  }

  // Updated resend OTP method using auth.sendOtp()
  Future<void> _resendOTP() async {
    if (!_isResendEnabled || _isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Resend OTP using auth.sendOtp()
      await Supabase.instance.client.auth.signInWithOtp(phone: widget.phoneNumber);


      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _startCountdown();
        _clearOTP();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP resent successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _getResendErrorMessage(e.message);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to resend OTP. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  String _getResendErrorMessage(String errorMessage) {
    if (errorMessage.toLowerCase().contains('too many')) {
      return 'Too many requests. Please wait before requesting another OTP.';
    } else if (errorMessage.toLowerCase().contains('phone')) {
      return 'Invalid phone number format.';
    } else {
      return 'Failed to resend OTP: $errorMessage';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2C3E50)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Header
              const Text(
                'Verify Phone Number',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'Enter the 6-digit code sent to\n${widget.phoneNumber}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF7F8C8D),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 45,
                    height: 55,
                    child: TextField(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(1),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF8F9FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE9ECEF),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF3498DB),
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE9ECEF),
                            width: 1,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1,
                          ),
                        ),
                      ),
                      onChanged: (value) => _onOTPChanged(value, index),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),

              // Error Message
              if (_errorMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: TextStyle(
                            color: Colors.red.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 30),

              // Verify Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3498DB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Text(
                    'Verify OTP',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Resend OTP Section
              Center(
                child: Column(
                  children: [
                    if (!_isResendEnabled)
                      Text(
                        'Resend OTP in $_formattedCountdown',
                        style: const TextStyle(
                          color: Color(0xFF7F8C8D),
                          fontSize: 14,
                        ),
                      )
                    else
                      TextButton(
                        onPressed: _isLoading ? null : _resendOTP,
                        child: Text(
                          _isLoading ? 'Resending...' : 'Resend OTP',
                          style: TextStyle(
                            color: _isLoading ? Color(0xFF7F8C8D) : Color(0xFF3498DB),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const Spacer(),

              // Footer
              Center(
                child: TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: const Text(
                    'Change Phone Number',
                    style: TextStyle(
                      color: Color(0xFF7F8C8D),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}