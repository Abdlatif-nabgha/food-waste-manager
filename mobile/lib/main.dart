import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'features/auth/presentation/screens/welcome_screen.dart';

void main() {
  runApp(const AntiFoodWasteApp());
}

class AntiFoodWasteApp extends StatelessWidget {
  const AntiFoodWasteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AntiFoodWaste',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        // Set standard app-wide styles
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textDark,
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}
