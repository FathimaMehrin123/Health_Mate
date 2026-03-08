import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_mate/features/activity/presentation/screens/activity_screen.dart';
import 'package:health_mate/features/authentication/presentation/screens/profile_setup_screen.dart';
import 'package:health_mate/features/sleep/presentation/bloc/sleep_bloc.dart';
import 'package:health_mate/features/sleep/presentation/sleep_screen.dart';
import 'package:health_mate/injection_container.dart' as di;


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
        // Splash screen route - shows app splash and checks if user is logged in
        return _fadeRoute(const Placeholder());

      case onboarding:
        // Onboarding route - shows onboarding screens for new users
        return _fadeRoute(const Placeholder());

      case profile:
        // Profile setup route - allows user to complete their profile
        return _slideRoute(const ProfileSetupScreen());

      case dashboard:
        // Dashboard route - main screen showing health overview
        return _fadeRoute(const Placeholder());

      case activity:
        // Activity tracking route - shows user activity data and tracking
        return _slideRoute(const ActivityScreen());

      case sleep:
        // Sleep tracking route - shows sleep data, charts, and analytics
        // BlocProvider wraps SleepScreen to provide SleepBloc to the screen
        return _slideRoute(
          BlocProvider<SleepBloc>(
            create: (context) => di.sl<SleepBloc>(),
            child: const SleepScreen(),
          ),
        );

      case achievements:
        // Achievements route - shows user achievements and badges
        return _slideRoute(const Placeholder());

      case settingsRoute:
        // Settings route - app settings and preferences
        return _slideRoute(const Placeholder());

      case posture:
        // Posture detection route - shows posture analysis and alerts
        return _slideRoute(const Placeholder());

      default:
        // Default route - fallback to profile setup screen
        return _fadeRoute(const ProfileSetupScreen());
    }
  }

  // ── Slide Route Animation ──
  // Creates a slide transition animation from right to left
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
  // Creates a fade in/out transition animation
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