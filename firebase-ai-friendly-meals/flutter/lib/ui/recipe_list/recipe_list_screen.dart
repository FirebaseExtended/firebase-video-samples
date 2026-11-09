import 'package:flutter/material.dart';

import '../../data/model/recipe.dart';
import '../shared/loading_indicator.dart';
import '../theme/app_theme.dart';
import 'recipe_list_controller.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({
    super.key,
    required this.controller,
    required this.openRecipeScreen,
    required this.openFilterScreen,
  });

  final RecipeListController controller;
  final ValueChanged<String> openRecipeScreen;
  final VoidCallback openFilterScreen;

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.controller.recipes.isEmpty && !widget.controller.loading) {
      widget.controller.initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final recipes = widget.controller.recipes;
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(68),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'All Recipes',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: widget.openFilterScreen,
                      tooltip: 'Filter',
                      icon: const Icon(Icons.filter_list),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: widget.controller.loading && recipes.isEmpty
              ? const Center(child: LoadingIndicator())
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  itemCount: recipes.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return RecipeCard(
                      key: ValueKey(recipe.id),
                      openRecipeScreen: widget.openRecipeScreen,
                      recipe: recipe,
                    );
                  },
                ),
        );
      },
    );
  }
}

class RecipeCard extends StatelessWidget {
  const RecipeCard({
    super.key,
    required this.openRecipeScreen,
    required this.recipe,
  });

  final ValueChanged<String> openRecipeScreen;
  final RecipeListItem recipe;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: Colors.white,
      elevation: 2,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openRecipeScreen(recipe.id),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 80,
                  height: 80,
                  color: AppColors.lightTeal,
                  child: recipe.imageUri != null && recipe.imageUri!.isNotEmpty
                      ? Image.network(
                          recipe.imageUri!,
                          fit: BoxFit.cover,
                          width: 80,
                          height: 80,
                          semanticLabel: 'Recipe image',
                          errorBuilder: (_, _, _) => Image.asset(
                            'assets/images/ic_launcher_no_bg.png',
                            fit: BoxFit.cover,
                            semanticLabel: 'App icon',
                          ),
                        )
                      : Image.asset(
                          'assets/images/ic_launcher_no_bg.png',
                          fit: BoxFit.cover,
                          semanticLabel: 'App icon',
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                        height: 20 / 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        for (int index = 1; index <= 5; index++)
                          _AverageRatingIcon(
                            index: index,
                            rating: recipe.averageRating,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AverageRatingIcon extends StatelessWidget {
  const _AverageRatingIcon({
    required this.index,
    required this.rating,
  });

  final int index;
  final double rating;

  @override
  Widget build(BuildContext context) {
    final IconData iconData;
    final Color iconTint;

    if (rating >= index) {
      iconData = Icons.star;
      iconTint = AppColors.selectedStarColor;
    } else if (rating > index - 1) {
      iconData = Icons.star_half;
      iconTint = AppColors.selectedStarColor;
    } else {
      iconData = Icons.star;
      iconTint = AppColors.unselectedStarColor;
    }

    return Icon(
      iconData,
      size: 16,
      color: iconTint,
    );
  }
}
