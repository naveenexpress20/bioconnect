import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // ✅ Import Firebase
import 'screens/login_screen.dart';
import 'screens/signup_page.dart';
import 'screens/otp_page.dart';
import 'screens/home_page.dart';
import 'screens/family_page.dart';
import 'screens/room_page.dart';
import 'routes.dart';  // Contains the AppRoutes class

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ Ensure Flutter bindings
  await Firebase.initializeApp(); // ✅ Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Name',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 18),
          bodyMedium: TextStyle(fontSize: 16),
        ),
      ),
      initialRoute: AppRoutes.login,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.login:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case AppRoutes.signup:
            return MaterialPageRoute(builder: (_) => const SignupPage());
          case AppRoutes.otp:
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(builder: (_) => OtpPage(verificationId: args?['verificationId'] ?? ''));
          case AppRoutes.home:
            return MaterialPageRoute(builder: (_) => const HomePage());
          case AppRoutes.family:
            return MaterialPageRoute(builder: (_) => const FamilyPage());
          case AppRoutes.room:
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => RoomPage(
                roomCode: args?['roomCode'] ?? 'UNKNOWN',
                isCreator: args?['isCreator'] ?? false,
              ),
            );
          default:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
      },
    );
  }
}
