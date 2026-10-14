import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../data/app_repositories.dart';
import '../../data/datasource/storage_remote_datasource.dart';
import '../../data/schema/meal_schema.dart';
import '../shared/camera_component.dart';
import '../shared/loading_indicator.dart';
import '../theme/app_theme.dart';

class ScanMealViewState {
  const ScanMealViewState({
    this.imageBytes,
    this.mealSchema = const MealSchema(),
    this.scanLoading = false,
  });

  final Uint8List? imageBytes;
  final MealSchema mealSchema;
  final bool scanLoading;

  ScanMealViewState copyWith({
    Uint8List? imageBytes,
    MealSchema? mealSchema,
    bool? scanLoading,
  }) {
    return ScanMealViewState(
      imageBytes: imageBytes ?? this.imageBytes,
      mealSchema: mealSchema ?? this.mealSchema,
      scanLoading: scanLoading ?? this.scanLoading,
    );
  }
}

class ScanMealScreen extends StatefulWidget {
  const ScanMealScreen({
    super.key,
    required this.repositories,
    required this.showError,
  });

  final AppRepositories repositories;
  final VoidCallback showError;

  @override
  State<ScanMealScreen> createState() => _ScanMealScreenState();
}

class _ScanMealScreenState extends State<ScanMealScreen> {
  ScanMealViewState _viewState = const ScanMealViewState();

  Future<void> _onImageTaken(
    Uint8List? imageBytes,
    VoidCallback showError,
  ) async {
    if (imageBytes == null) {
      showError();
      return;
    }

    setState(() {
      _viewState = _viewState.copyWith(
        scanLoading: true,
        imageBytes: imageBytes,
      );
    });

    try {
      final base64Image = await imageBytesToBase64(imageBytes);
      final mealSchema =
          await widget.repositories.aiRepository.scanMeal(base64Image);

      if (!mounted) return;
      if (mealSchema == null) {
        setState(() {
          _viewState = _viewState.copyWith(scanLoading: false);
        });
        showError();
        return;
      }

      setState(() {
        _viewState = _viewState.copyWith(
          scanLoading: false,
          mealSchema: mealSchema,
        );
      });
    } catch (e) {
      debugPrint('Error scanning meal: $e');
      if (!mounted) return;
      setState(() {
        _viewState = _viewState.copyWith(scanLoading: false);
      });
      showError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageBytes = _viewState.imageBytes;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(68),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Scan Meal',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CameraComponent(
                  onImageTaken: _onImageTaken,
                  showError: widget.showError,
                  isTopBarIcon: true,
                ),
              ],
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: double.infinity,
              height: 275,
              color: Colors.grey.shade400,
              child: imageBytes != null
                  ? Image.memory(
                      imageBytes,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      semanticLabel: 'Recipe image',
                    )
                  : const Center(
                      child: Text(
                        'Could not load image',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'Nutritional Facts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _NutrientCard(
                  label: 'Protein',
                  value: _viewState.mealSchema.protein,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _NutrientCard(
                  label: 'Fat',
                  value: _viewState.mealSchema.fat,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _NutrientCard(
                  label: 'Carbs',
                  value: _viewState.mealSchema.carbs,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _NutrientCard(
                  label: 'Sugar',
                  value: _viewState.mealSchema.sugar,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_viewState.scanLoading) ...[
            const SizedBox(height: 48),
            const LoadingIndicator(),
          ],
          if (_viewState.mealSchema.ingredients.isNotEmpty)
            _IngredientsCard(ingredients: _viewState.mealSchema.ingredients),
        ],
      ),
    );
  }
}

class _NutrientCard extends StatelessWidget {
  const _NutrientCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.lightTeal,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.teal,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientsCard extends StatelessWidget {
  const _IngredientsCard({required this.ingredients});

  final List<String> ingredients;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Identified Ingredients',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.teal,
              ),
            ),
            const SizedBox(height: 12),
            ...ingredients.map((item) => _IngredientRow(text: item)),
          ],
        ),
      ),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: AppColors.lightTeal,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.check,
              size: 14,
              color: AppColors.teal,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
