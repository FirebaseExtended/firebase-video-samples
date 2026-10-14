import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../data/app_repositories.dart';
import '../../data/model/recipe.dart';
import '../../data/schema/recipe_schema.dart';
import '../shared/camera_component.dart';
import '../shared/loading_indicator.dart';
import '../theme/app_theme.dart';

class GenerateViewState {
  const GenerateViewState({
    this.ingredients = '',
    this.notes = '',
    this.ingredientsLoading = false,
    this.recipeLoading = false,
  });

  final String ingredients;
  final String notes;
  final bool ingredientsLoading;
  final bool recipeLoading;

  GenerateViewState copyWith({
    String? ingredients,
    String? notes,
    bool? ingredientsLoading,
    bool? recipeLoading,
  }) {
    return GenerateViewState(
      ingredients: ingredients ?? this.ingredients,
      notes: notes ?? this.notes,
      ingredientsLoading: ingredientsLoading ?? this.ingredientsLoading,
      recipeLoading: recipeLoading ?? this.recipeLoading,
    );
  }
}

class GenerateScreen extends StatefulWidget {
  const GenerateScreen({
    super.key,
    required this.repositories,
    required this.openRecipeScreen,
    required this.showError,
  });

  final AppRepositories repositories;
  final ValueChanged<String> openRecipeScreen;
  final VoidCallback showError;

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> {
  GenerateViewState _viewState = const GenerateViewState();
  late final TextEditingController _ingredientsController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _ingredientsController = TextEditingController();
    _notesController = TextEditingController();
    _loadCurrentUser();
    _loadOnDeviceModel();
  }

  @override
  void dispose() {
    _ingredientsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    try {
      if (widget.repositories.authRepository.currentUser == null) {
        final user =
            await widget.repositories.authRepository.createAnonymousAccount();
        await widget.repositories.databaseRepository.addUser(user);
      }
    } catch (e) {
      debugPrint('Error loading current user: $e');
    }
  }

  Future<void> _loadOnDeviceModel() async {
    try {
      await widget.repositories.aiRepository.loadOnDeviceModel();
    } catch (e) {
      debugPrint('Error loading on-device model: $e');
    }
  }

  void _onIngredientsUpdated(String ingredients) {
    setState(() {
      _viewState = _viewState.copyWith(ingredients: ingredients);
    });
  }

  void _onNotesUpdated(String notes) {
    setState(() {
      _viewState = _viewState.copyWith(notes: notes);
    });
  }

  Future<void> _onImageTaken(
    Uint8List? imageBytes,
    VoidCallback showError,
  ) async {
    if (imageBytes == null) {
      showError();
      return;
    }

    setState(() {
      _viewState = _viewState.copyWith(ingredientsLoading: true);
    });

    try {
      final ingredients = await widget.repositories.aiRepository
          .generateIngredients(imageBytes);
      if (!mounted) return;
      _ingredientsController.text = ingredients;
      setState(() {
        _viewState = _viewState.copyWith(
          ingredientsLoading: false,
          ingredients: ingredients,
        );
      });
    } catch (e) {
      debugPrint('Error generating ingredients from image: $e');
      if (!mounted) return;
      setState(() {
        _viewState = _viewState.copyWith(ingredientsLoading: false);
      });
      showError();
    }
  }

  Future<void> _generateRecipe(
    ValueChanged<String> openRecipeScreen,
    VoidCallback showError,
  ) async {
    setState(() {
      _viewState = _viewState.copyWith(recipeLoading: true);
    });

    try {
      final generatedRecipe = await widget.repositories.aiRepository
          .generateRecipe(_viewState.ingredients, _viewState.notes);

      if (generatedRecipe == null) {
        if (!mounted) return;
        setState(() {
          _viewState = _viewState.copyWith(recipeLoading: false);
        });
        showError();
        return;
      }

      Uint8List? recipeImage;
      try {
        recipeImage = await widget.repositories.aiRepository
            .generateRecipePhoto(generatedRecipe.title);
      } catch (e) {
        debugPrint('Error generating recipe photo: $e');
      }

      String? recipeImageUri;
      if (recipeImage != null) {
        try {
          recipeImageUri =
              await widget.repositories.storageRepository.addImage(recipeImage);
        } catch (e) {
          debugPrint('Error uploading recipe image: $e');
        }
      }

      final storedRecipeId =
          await widget.repositories.databaseRepository.addRecipe(
        _toRecipe(
          generatedRecipe,
          authorId:
              widget.repositories.authRepository.currentUser?.uid ?? '',
          imageUri: recipeImageUri,
        ),
      );

      if (!mounted) return;
      setState(() {
        _viewState = _viewState.copyWith(recipeLoading: false);
      });

      openRecipeScreen(storedRecipeId);
    } catch (e) {
      debugPrint('Error generating recipe: $e');
      if (!mounted) return;
      setState(() {
        _viewState = _viewState.copyWith(recipeLoading: false);
      });
      showError();
    }
  }

  Recipe _toRecipe(
    RecipeSchema schema, {
    required String authorId,
    required String? imageUri,
  }) {
    return Recipe(
      title: schema.title,
      instructions: schema.instructions,
      ingredients: schema.ingredients,
      authorId: authorId,
      tags: schema.tags,
      prepTime: schema.prepTime,
      cookTime: schema.cookTime,
      servings: schema.servings,
      imageUri: imageUri,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ingredientsHint = _viewState.ingredientsLoading
        ? 'Loading…'
        : 'e.g., pasta, tomato, garlic, bacon, eggs';

    final generateButtonEnabled = _viewState.ingredients.trim().isNotEmpty &&
        !_viewState.recipeLoading &&
        !_viewState.ingredientsLoading;

    final borderSide = BorderSide(color: Colors.grey.shade400);
    final outlineBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: borderSide,
    );

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(68),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: const Text(
              'New recipe',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'List your ingredients',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(
              height: 120,
              child: TextField(
                controller: _ingredientsController,
                onChanged: _onIngredientsUpdated,
                enabled: !_viewState.ingredientsLoading,
                expands: true,
                maxLines: null,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: ingredientsHint,
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: outlineBorder,
                  enabledBorder: outlineBorder,
                  focusedBorder: outlineBorder,
                  disabledBorder: outlineBorder,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            CameraComponent(
              onImageTaken: _onImageTaken,
              showError: widget.showError,
              isTopBarIcon: false,
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Any special notes or cuisines?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(
              height: 120,
              child: TextField(
                controller: _notesController,
                onChanged: _onNotesUpdated,
                expands: true,
                maxLines: null,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: 'e.g., vegetarian, gluten-free, Italian',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: outlineBorder,
                  enabledBorder: outlineBorder,
                  focusedBorder: outlineBorder,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: generateButtonEnabled
                    ? () => _generateRecipe(
                          widget.openRecipeScreen,
                          widget.showError,
                        )
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Generate Recipe',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_viewState.recipeLoading || _viewState.ingredientsLoading) ...[
              const SizedBox(height: 24),
              const LoadingIndicator(),
            ],
          ],
        ),
      ),
    );
  }
}
