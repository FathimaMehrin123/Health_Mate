import 'package:flutter/material.dart';
import 'package:health_mate/core/theme/app_theme.dart';
import 'package:health_mate/features/authentication/presentation/screens/profile_setup_screen.dart';
import 'package:health_mate/injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: ProfileSetupScreen(),
    );
  }
}
