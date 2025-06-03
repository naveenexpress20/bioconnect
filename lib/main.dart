import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ✅ Use correct relative imports for local files
import 'screens/login_screen.dart';
import 'screens/signup_page.dart';
import 'screens/otp_page.dart';
import 'screens/home_page.dart';
import 'screens/family_page.dart';
import 'screens/room_page.dart';
import 'screens/family_member_stats.dart';
import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: 'https://kzlsaglruwsorekgatft.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt6bHNhZ2xydXdzb3Jla2dhdGZ0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgyNDMwNTgsImV4cCI6MjA2MzgxOTA1OH0.I82DbHLJFPdSgBxaiBV4y2H1Hvy3Jqa9vefvKMmmO_I', // ✅ Your actual Supabase anon key
    );
    print("✅ Supabase Initialized Successfully");

    // 🟢 FORCE LOGOUT: Clear any existing session to always show login
    try {
      await Supabase.instance.client.auth.signOut();
      print("🔄 Cleared existing session - will show login screen");
    } catch (e) {
      print("ℹ️  No existing session to clear");
    }

  } catch (e) {
    print("❌ Error Initializing Supabase: $e");
  }

  runApp(const BioConnectApp());
}

class BioConnectApp extends StatelessWidget {
  const BioConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BioConnect - Family Health Monitor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black87,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),

      /// 🟢 DIRECT LOGIN: Skip splash, start with login screen
      home: const LoginScreen(),

      /// 🟢 This maps route names to screens
      routes: AppRoutes.routes,
    );
  }
}

/// Authentication Wrapper Widget
/// Use this to wrap screens that require authentication
class AuthWrapper extends StatelessWidget {
  final Widget child;

  const AuthWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final session = snapshot.hasData ? snapshot.data!.session : null;

        if (session != null) {
          // User is authenticated, show the protected screen
          return child;
        } else {
          // User is not authenticated, redirect to login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.login,
                  (route) => false,
            );
          });

          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}