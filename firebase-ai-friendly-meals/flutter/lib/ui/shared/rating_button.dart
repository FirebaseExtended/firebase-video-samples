import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RatingButton extends StatelessWidget {
  const RatingButton({
    super.key,
    required this.rating,
    required this.isSelected,
    required this.isFilled,
    required this.onClick,
  });

  final int rating;
  final bool isSelected;
  final bool isFilled;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    final Color iconTint;
    if (isSelected) {
      iconTint = Colors.white;
    } else if (isFilled) {
      iconTint = AppColors.selectedStarColor;
    } else {
      iconTint = AppColors.unselectedStarColor;
    }

    return Semantics(
      label: '$rating Stars',
      button: true,
      child: InkWell(
        onTap: onClick,
        customBorder: const CircleBorder(),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? AppColors.teal : Colors.white,
            border: Border.all(
              width: 1,
              color: isSelected ? AppColors.teal : AppColors.borderColor,
            ),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.star,
            size: 24,
            color: iconTint,
          ),
        ),
      ),
    );
  }
}
