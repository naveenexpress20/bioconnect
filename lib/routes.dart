import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/signup_page.dart';
import 'screens/otp_page.dart';
import 'screens/home_page.dart';
import 'screens/family_page.dart';
import 'screens/room_page.dart';
import 'screens/family_member_stats.dart';

class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String otp = '/otp';
  static const String home = '/home';
  static const String family = '/family';
  static const String room = '/room';
  static const String memberStats = '/member-stats';

  static Map<String, WidgetBuilder> get routes {
    return {
      login: (context) => const LoginScreen(),
      signup: (context) => const SignupPage(),
      otp: (context) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        return OtpPage(
          phoneNumber: args?['phoneNumber'] ?? '',
          verificationId: args?['verificationId'] ?? '',
        );
      },
      home: (context) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        return HomePage(
          userName: args?['userName'] ?? 'User',
        );
      },
      family: (context) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        return FamilyPage(isCreator: args?['isCreator'] ?? false);
      },
      room: (context) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        return RoomPage(
          roomCode: args?['roomCode'] ?? '',
        );
      },
      memberStats: (context) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        return FamilyMemberStatsPage(
          memberId: args?['memberId'] ?? '',
          memberName: args?['memberName'] ?? 'Member',
          memberAge: args?['memberAge'] ?? '0',
          memberImage: args?['memberImage'] ?? '',
        );
      },
    };
  }

  // Alternative route generation method using generateRoute
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;

    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        );

      case signup:
        return MaterialPageRoute(
          builder: (context) => const SignupPage(),
        );

      case otp:
        return MaterialPageRoute(
          builder: (context) => OtpPage(
            phoneNumber: args?['phoneNumber'] ?? '',
            verificationId: args?['verificationId'] ?? '',
          ),
        );

      case home:
        return MaterialPageRoute(
          builder: (context) => HomePage(
            userName: args?['userName'] ?? 'User',
          ),
        );

      case family:
        return MaterialPageRoute(
          builder: (context) => FamilyPage(
            isCreator: args?['isCreator'] ?? false,
          ),
        );

      case room:
        return MaterialPageRoute(
          builder: (context) => RoomPage(
            roomCode: args?['roomCode'] ?? '',
          ),
        );

      case memberStats:
        return MaterialPageRoute(
          builder: (context) => FamilyMemberStatsPage(
            memberId: args?['memberId'] ?? '',
            memberName: args?['memberName'] ?? 'Member',
            memberAge: args?['memberAge'] ?? '0',
            memberImage: args?['memberImage'] ?? '',
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        );
    }
  }

  // Helper method for navigation with parameters
  static void navigateToOtp(BuildContext context, {
    required String phoneNumber,
    required String verificationId,
  }) {
    Navigator.pushNamed(
      context,
      otp,
      arguments: {
        'phoneNumber': phoneNumber,
        'verificationId': verificationId,
      },
    );
  }

  static void navigateToHome(BuildContext context, {
    required String userName,
  }) {
    Navigator.pushReplacementNamed(
      context,
      home,
      arguments: {
        'userName': userName,
      },
    );
  }

  static void navigateToFamily(BuildContext context, {
    required bool isCreator,
  }) {
    Navigator.pushNamed(
      context,
      family,
      arguments: {
        'isCreator': isCreator,
      },
    );
  }

  static void navigateToRoom(BuildContext context, {
    required String roomCode,
  }) {
    Navigator.pushNamed(
      context,
      room,
      arguments: {
        'roomCode': roomCode,
      },
    );
  }

  static void navigateToMemberStats(BuildContext context, {
    required String memberId,
    required String memberName,
    required String memberAge,
    required String memberImage,
  }) {
    Navigator.pushNamed(
      context,
      memberStats,
      arguments: {
        'memberId': memberId,
        'memberName': memberName,
        'memberAge': memberAge,
        'memberImage': memberImage,
      },
    );
  }

  // Direct navigation methods (recommended for complex parameters)
  static void navigateToOtpDirect(BuildContext context, {
    required String phoneNumber,
    required String verificationId,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpPage(
          phoneNumber: phoneNumber,
          verificationId: verificationId,
        ),
      ),
    );
  }

  static void navigateToHomeDirect(BuildContext context, {
    required String userName,
  }) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomePage(
          userName: userName,
        ),
      ),
    );
  }

  static void navigateToFamilyDirect(BuildContext context, {
    required bool isCreator,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FamilyPage(
          isCreator: isCreator,
        ),
      ),
    );
  }

  static void navigateToRoomDirect(BuildContext context, {
    required String roomCode,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoomPage(
          roomCode: roomCode,
        ),
      ),
    );
  }

  static void navigateToMemberStatsDirect(BuildContext context, {
    required String memberId,
    required String memberName,
    required String memberAge,
    required String memberImage,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FamilyMemberStatsPage(
          memberId: memberId,
          memberName: memberName,
          memberAge: memberAge,
          memberImage: memberImage,
        ),
      ),
    );
  }

  // Utility methods for common navigation patterns
  static void pushAndClearStack(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
          (route) => false,
      arguments: arguments,
    );
  }

  static void popToRoot(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  static void popAndPushNamed(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.popAndPushNamed(
      context,
      routeName,
      arguments: arguments,
    );
  }
}