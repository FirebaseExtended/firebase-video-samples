import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class RecipeGeneratorScreen extends StatefulWidget {
  const RecipeGeneratorScreen({super.key});

  @override
  State<RecipeGeneratorScreen> createState() => _RecipeGeneratorScreenState();
}

class _RecipeGeneratorScreenState extends State<RecipeGeneratorScreen> {
  bool _showRecipeCard = false;
  String _generatedRecipe = "";

  void _handleGenerateRecipe() {
    setState(() {
      _generatedRecipe = """
## Garlic Chicken and Rice Skillet

A simple and flavorful one-pan meal.

**Ingredients:**
- 1 lb boneless, skinless chicken thighs, cut into bite-sized pieces
- 1 cup long-grain white rice
- 2 cups chicken broth
- 5 cloves garlic, minced
- 1 onion, chopped
- 2 tbsp olive oil
- 1 tsp dried oregano
- Salt and pepper to taste
- Fresh parsley, chopped (for garnish)

**Instructions:**
1. Heat olive oil in a large skillet or pot over medium-high heat.
2. Season chicken with salt, pepper, and oregano. Add to the skillet and cook until browned on all sides. Remove chicken and set aside.
3. In the same skillet, add the chopped onion and cook until softened, about 3-4 minutes.
4. Stir in the minced garlic and cook for another minute until fragrant.
5. Add the rice to the skillet and toast for 1-2 minutes, stirring constantly.
6. Pour in the chicken broth, scraping up any browned bits from the bottom of the pan. Bring to a simmer.
7. Return the chicken to the skillet. Reduce heat to low, cover, and cook for 18-20 minutes, or until the rice is tender and the liquid has been absorbed.
8. Fluff the rice with a fork, garnish with fresh parsley, and serve immediately.
""";
      _showRecipeCard = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Friendly Meals')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16.0),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Enter ingredients (comma separated)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Notes or preferred cuisines',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32.0),
              TextButton(
                onPressed: _handleGenerateRecipe,
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: const TextStyle(fontSize: 18.0),
                ),
                child: const Text('Generate Recipe'),
              ),
              const SizedBox(height: 24.0),
              Visibility(
                visible: _showRecipeCard,
                child: Card(
                  elevation: 2.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [MarkdownBody(data: _generatedRecipe)],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
