import 'package:equatable/equatable.dart';
import 'package:firebase_ai_friendly_meals/core/exceptions/ai_exceptions.dart';
import 'package:firebase_ai_friendly_meals/data/model/recipe.dart';
import 'package:firebase_ai_friendly_meals/data/repository/ai_repository.dart';
import 'package:firebase_ai_friendly_meals/injection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    AIRepository? aiRepository,
  }) : _aiRepository = aiRepository ?? getIt<AIRepository>(),
       super(const HomeState());

  final AIRepository _aiRepository;

  void onIngredientsChanged(String ingredients) {
    emit(
      state.copyWith(
        ingredients: ingredients,
        errorMessage: () => null,
        status: HomeViewState.initial,
      ),
    );
  }

  void onNotesChanged(String notes) {
    emit(
      state.copyWith(
        notes: notes,
        errorMessage: () => null,
        status: HomeViewState.initial,
      ),
    );
  }

  void onImageSelected(Uint8List image) {
    emit(
      state.copyWith(
        selectedImage: () => image,
        errorMessage: () => null,
        status: HomeViewState.initial,
      ),
    );
  }

  Future<void> onGenerateIngredients() async {
    if (state.selectedImage == null) {
      throw Exception('No image selected');
    }

    emit(
      state.copyWith(
        status: HomeViewState.loading,
        errorMessage: () => null,
      ),
    );

    try {
      final ingredients = await _aiRepository.generateIngredients(
        state.selectedImage!,
      );

      emit(
        state.copyWith(
          ingredients: ingredients,
          status: HomeViewState.success,
        ),
      );
    } on AIException catch (e) {
      emit(
        state.copyWith(
          status: HomeViewState.failure,
          errorMessage: () => _getErrorMessage(e),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: HomeViewState.failure,
          errorMessage: () => 'An unexpected error occurred. Please try again.',
        ),
      );
    }
  }

  Future<void> onGenerateRecipe() async {
    if (state.ingredients.trim().isEmpty) {
      emit(
        state.copyWith(
          status: HomeViewState.failure,
          errorMessage: () => 'Please add some ingredients first',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: HomeViewState.loading,
        errorMessage: () => null,
      ),
    );

    // TODO: Call the repository to generate the recipe
  }

  String _getErrorMessage(AIException exception) {
    return switch (exception) {
      ValidationException _ => exception.message,
      ImageAnalysisException _ =>
        'Could not analyze the image. Please try with a clearer photo.',
      AIGenerationException _ =>
        'Failed to generate content. Please try again.',
      NetworkException _ =>
        'Network error. Please check your connection and try again.',
    };
  }
}
