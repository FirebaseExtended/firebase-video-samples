import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum BottomNavTab {
  scanMeal('Scan Meal', Icons.photo_camera_outlined),
  generate('Generate', Icons.auto_awesome_outlined),
  recipeList('Recipes', Icons.restaurant_outlined),
  groceryList('Grocery List', Icons.fact_check_outlined);

  const BottomNavTab(this.label, this.icon);
  final String label;
  final IconData icon;
}

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  final BottomNavTab selectedTab;
  final ValueChanged<BottomNavTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedTab.index,
      indicatorColor: Colors.transparent,
      onDestinationSelected: (index) {
        onTabSelected(BottomNavTab.values[index]);
      },
      destinations: BottomNavTab.values.map((tab) {
        final isSelected = tab == selectedTab;
        return NavigationDestination(
          icon: Icon(
            tab.icon,
            color: isSelected ? AppColors.teal : null,
          ),
          selectedIcon: Icon(
            tab.icon,
            color: AppColors.teal,
          ),
          label: tab.label,
        );
      }).toList(),
    );
  }
}
