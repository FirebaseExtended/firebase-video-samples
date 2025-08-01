import 'package:firebase_ai_friendly_meals/core/theme/colors.dart';
import 'package:firebase_ai_friendly_meals/core/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';

class BorderedCard extends StatelessWidget {
  const BorderedCard({
    required this.child,
    this.isLoading = false,
    this.backgroundColor = AppColors.mediumFirebaseYellow,
    this.borderColor = AppColors.darkFirebaseYellow,
    super.key,
  });

  final Widget child;
  final Color backgroundColor;
  final Color borderColor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),

          if (isLoading) const _LoadingOverlay(),
        ],
      ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const LoadingIndicator(),
      ),
    );
  }
}
