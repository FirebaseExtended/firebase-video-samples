import 'package:firebase_ai_friendly_meals/core/theme/colors.dart';
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox.square(
        dimension: 64,
        child: CircularProgressIndicator(
          color: AppColors.darkFirebaseYellow,
          backgroundColor: AppColors.lightFirebaseYellow,
        ),
      ),
    );
  }
}
