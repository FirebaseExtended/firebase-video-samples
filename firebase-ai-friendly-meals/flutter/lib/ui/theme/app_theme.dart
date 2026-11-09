import 'package:flutter/material.dart';

class AppColors {
  static const Color teal = Color(0xFF1EB980);
  static const Color lightTeal = Color(0xFFE0F2F1);
  static const Color lightGray = Color(0xFFF3F4F6);
  static const Color charcoal = Color(0xFF36454F);
  static const Color textColor = Color(0xFF1F2937);
  static const Color lightTextColor = Color(0xFFF8F9FA);
  static const Color selectedStarColor = Color(0xFFFFC107);
  static const Color unselectedStarColor = Color(0xFF9CA3AF);
  static const Color borderColor = Color(0xFFE5E7EB);
}

class FriendlyMealsTheme {
  static ThemeData get lightTheme {
    const colorScheme = ColorScheme.light(
      primary: AppColors.teal,
      secondary: AppColors.lightTeal,
      surface: AppColors.lightGray,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: AppColors.textColor,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      primaryColor: AppColors.teal,
      scaffoldBackgroundColor: AppColors.lightGray,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightGray,
        foregroundColor: AppColors.textColor,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          fontSize: 16,
          height: 24 / 16,
          letterSpacing: 0.5,
          color: AppColors.textColor,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textColor,
        ),
      ),
    );
  }
}
