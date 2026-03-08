import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_mate/core/route/app_router.dart';
import 'package:health_mate/core/theme/app_theme.dart';
import 'package:health_mate/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:health_mate/features/activity/presentation/bloc/activity_bloc.dart';
import 'package:health_mate/features/sleep/presentation/bloc/sleep_bloc.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize all dependencies (Hive, repositories, use cases, BLoCs)
  // This single call handles ALL initialization for the entire app
  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      // All BLoCs are registered here and available throughout the entire app
      providers: [
        // Authentication BLoC - handles user login, signup, and session management
        BlocProvider<AuthBloc>(
          create: (context) => di.sl<AuthBloc>(),
        ),
        // Activity BLoC - handles activity tracking and classification
        BlocProvider<ActivityBloc>(
          create: (context) => di.sl<ActivityBloc>(),
        ),
        // Sleep BLoC - handles sleep tracking and analysis
        BlocProvider<SleepBloc>(
          create: (context) => di.sl<SleepBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Health Companion',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: AppRouter.activity, // For testing activity screen
      ),
    );
  }
}