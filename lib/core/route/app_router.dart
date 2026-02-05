import 'package:flutter/material.dart';
import 'package:health_mate/features/activity/presentation/screens/activity_screen.dart';
import 'package:health_mate/features/authentication/presentation/screens/profile_setup_screen.dart';
/*
class AppRouter {
  static const String profile = '/profile';
  static const String dashboard = '/dashboard';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileSetupScreen(),
        );
      case dashboard:
        return MaterialPageRoute(
          builder: (_) => const DashboardScreen(), // Create this next
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const ProfileSetupScreen(),
        );
    }
  }
}

*/

class AppRouter {
  // Route Names
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String profile = '/profile';
  static const String dashboard = '/dashboard';
  static const String activity = '/activity';
  static const String sleep = '/sleep';
  static const String achievements = '/achievements';
  static const String settingsRoute = '/settings';
  static const String posture = '/posture';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _fadeRoute(const Placeholder());

      case onboarding:
        return _fadeRoute(const Placeholder());

      case profile:
        return _slideRoute(const ProfileSetupScreen());

      case dashboard:
        return _fadeRoute(const Placeholder());

      case activity:
        return _slideRoute(const ActivityScreen());

      case sleep:
        return _slideRoute(const Placeholder());

      case achievements:
        return _slideRoute(const Placeholder());

      case settingsRoute:
        return _slideRoute(const Placeholder());

      case posture:
        return _slideRoute(const Placeholder());

      default:
        return _fadeRoute(const ProfileSetupScreen());
    }
  }

  // ── Slide Route Animation ──
  static Route _slideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        final tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  // ── Fade Route Animation ──
  static Route _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}
