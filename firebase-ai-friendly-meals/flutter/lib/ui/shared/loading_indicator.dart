import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 24),
      child: SizedBox(
        width: double.infinity,
        child: Center(
          child: SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator(
              color: AppColors.teal,
              backgroundColor: AppColors.lightTeal,
            ),
          ),
        ),
      ),
    );
  }
}
