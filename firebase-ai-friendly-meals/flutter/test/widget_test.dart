import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendly_meals/data/model/grocery_item.dart';
import 'package:friendly_meals/data/model/recipe.dart';
import 'package:friendly_meals/data/schema/meal_schema.dart';
import 'package:friendly_meals/data/schema/recipe_schema.dart';
import 'package:friendly_meals/data/schema/store_schema.dart';
import 'package:friendly_meals/ui/shared/bottom_nav_bar.dart';
import 'package:friendly_meals/ui/shared/rating_button.dart';
import 'package:friendly_meals/ui/theme/app_theme.dart';

void main() {
  testWidgets('BottomNavBar renders all 4 FriendlyMeals tabs and switches tabs',
      (WidgetTester tester) async {
    BottomNavTab currentTab = BottomNavTab.generate;

    await tester.pumpWidget(
      MaterialApp(
        theme: FriendlyMealsTheme.lightTheme,
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              bottomNavigationBar: BottomNavBar(
                selectedTab: currentTab,
                onTabSelected: (tab) => setState(() => currentTab = tab),
              ),
            );
          },
        ),
      ),
    );

    expect(find.text('Scan Meal'), findsOneWidget);
    expect(find.text('Generate'), findsOneWidget);
    expect(find.text('Recipes'), findsOneWidget);
    expect(find.text('Grocery List'), findsOneWidget);

    await tester.tap(find.text('Grocery List'));
    await tester.pump();
    expect(currentTab, BottomNavTab.groceryList);
  });

  testWidgets('RatingButton renders and triggers callback',
      (WidgetTester tester) async {
    int? tappedRating;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RatingButton(
            rating: 4,
            isSelected: true,
            isFilled: false,
            onClick: () => tappedRating = 4,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.star));
    await tester.pump();
    expect(tappedRating, 4);
  });

  test('Schemas and models serialize and deserialize accurately', () {
    final recipeSchema = RecipeSchema.fromJson({
      'title': 'Pasta Carbonara',
      'prepTime': '10 mins',
      'cookTime': '15 mins',
      'servings': '2',
      'ingredients': ['Pasta', 'Eggs', 'Pecorino'],
      'instructions': 'Boil pasta and mix.',
      'tags': ['Italian', 'Quick'],
    });
    expect(recipeSchema.title, 'Pasta Carbonara');
    expect(recipeSchema.tags, ['Italian', 'Quick']);

    final mealSchema = MealSchema.fromJson({
      'ingredients': ['Chicken', 'Rice'],
      'fat': '12g',
      'carbs': '45g',
      'sugar': '2g',
      'protein': '35g',
    });
    expect(mealSchema.protein, '35g');

    final storeResult = StoreFinderResult.fromJson({
      'stores': [
        {
          'name': 'Fresh Market',
          'address': '123 Main St',
          'distance': '0.5 mi',
          'openNow': true,
          'closingSoon': false,
          'hasParking': true,
          'parkingDetails': 'Free lot',
          'mapUrl': 'https://maps.google.com',
        }
      ],
    });
    expect(storeResult.stores.single.name, 'Fresh Market');

    final recipe = Recipe.fromMap({'title': recipeSchema.title});
    expect(recipe.title, 'Pasta Carbonara');

    final grocery = GroceryItem.fromMap(
      {'userId': 'u1', 'name': 'Tomatoes', 'checked': true},
      docId: 'g1',
    );
    expect(grocery.id, 'g1');
    expect(grocery.checked, true);
  });
}
