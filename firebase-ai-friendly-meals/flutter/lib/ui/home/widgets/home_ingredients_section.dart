import 'package:firebase_ai_friendly_meals/core/widgets/bordered_card.dart';
import 'package:firebase_ai_friendly_meals/core/widgets/sized_text_field.dart';
import 'package:firebase_ai_friendly_meals/ui/home/cubit/home_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class HomeIngredientsBox extends StatelessWidget {
  const HomeIngredientsBox({
    required this.ingredientsController,
    required this.notesController,
    super.key,
  });

  final TextEditingController ingredientsController;
  final TextEditingController notesController;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listenWhen: (previous, current) =>
          previous.ingredients != current.ingredients ||
          previous.status != current.status,
      listener: (context, state) {
        ingredientsController.text = state.ingredients;
        notesController.text = state.notes;
      },
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.ingredients != current.ingredients,
      builder: (context, state) {
        return BorderedCard(
          isLoading: state.status.isLoading,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              _IngredientsTextField(controller: ingredientsController),
              _NotesTextField(controller: notesController),
              const _GenerateButton(),
            ],
          ),
        );
      },
    );
  }
}

class _IngredientsTextField extends StatelessWidget {
  const _IngredientsTextField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final state = context.read<HomeCubit>().state;
    final ingredients = state.ingredients;
    final isLoading = state.status.isLoading;

    return Stack(
      children: [
        SizedTextField(
          controller: controller,
          onChanged: (value) {
            context.read<HomeCubit>().onIngredientsChanged(value);
          },
          hintText: 'Enter your list of ingredients',
          enabled: !isLoading,
        ),

        if (ingredients.isEmpty)
          _CameraIconOverlay(
            isEnabled: !isLoading,
          ),
      ],
    );
  }
}

class _NotesTextField extends StatelessWidget {
  const _NotesTextField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return SizedTextField(
      controller: controller,
      onChanged: (value) => context.read<HomeCubit>().onNotesChanged(value),
      hintText: 'Any notes or preferred cuisines?',
    );
  }
}

class _GenerateButton extends StatelessWidget {
  const _GenerateButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) =>
          previous.ingredients != current.ingredients ||
          previous.status != current.status,
      builder: (context, state) {
        final isEnabled =
            state.ingredients.isNotEmpty && !state.status.isLoading;
        return ElevatedButton(
          onPressed: isEnabled ? () => _onPressed(context) : null,
          child: const Text('Generate Recipe'),
        );
      },
    );
  }

  void _onPressed(BuildContext context) {
    context.read<HomeCubit>().onGenerateRecipe();
  }
}

class _CameraIconOverlay extends StatelessWidget {
  const _CameraIconOverlay({required this.isEnabled});

  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 12,
      right: 12,
      child: GestureDetector(
        onTap: isEnabled ? () => _onCameraPressed(context) : null,
        child: Icon(
          Icons.camera_alt,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  Future<void> _onCameraPressed(BuildContext context) async {
    final cubit = context.read<HomeCubit>();
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      final bytes = await image.readAsBytes();
      cubit.onImageSelected(bytes);
      await cubit.onGenerateIngredients();
    }
  }
}
