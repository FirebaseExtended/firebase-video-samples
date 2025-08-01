import 'package:flutter/material.dart';

class AppTypography {
  static const TextTheme textTheme = TextTheme(
    bodyLarge: TextStyle(
      fontFamily: 'Default',
      fontWeight: FontWeight.normal,
      fontSize: 16.0,
      height: 1.5, // line height = 24sp / 16sp = 1.5
      letterSpacing: 0.5,
    ),
  );
}
