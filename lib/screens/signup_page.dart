import 'package:flutter/material.dart';
import 'home_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController genderController = TextEditingController();

  void _handleSignUp() {
    if (_formKey.currentState!.validate()) {
      // Simulate registration success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration Successful!")),
      );

      // Navigate to HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Sign Up", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              _buildLabel("First Name"),
              _buildTextField(firstNameController, "Enter your first name", validator: (value) {
                return (value!.isEmpty) ? "Required field" : null;
              }),

              _buildLabel("Email"),
              _buildTextField(emailController, "Enter your email", keyboardType: TextInputType.emailAddress, validator: (value) {
                return (!value!.contains("@")) ? "Enter a valid email" : null;
              }),

              _buildLabel("Password"),
              _buildTextField(passwordController, "Enter your password", isObscure: true, validator: (value) {
                return (value!.length < 6) ? "Password must be at least 6 characters" : null;
              }),

              _buildLabel("Username"),
              _buildTextField(usernameController, "Enter your username", validator: (value) {
                return (value!.isEmpty) ? "Required field" : null;
              }),

              _buildLabel("Age"),
              _buildTextField(ageController, "Enter your age", keyboardType: TextInputType.number, validator: (value) {
                return (int.tryParse(value!) == null) ? "Enter a valid number" : null;
              }),

              _buildLabel("Gender"),
              _buildTextField(genderController, "Enter your gender"),

              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _handleSignUp,
                  child: const Text("Register"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String hint, {
        bool isObscure = false,
        TextInputType keyboardType = TextInputType.text,
        String? Function(String?)? validator,
      }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(),
      ),
    );
  }
}

