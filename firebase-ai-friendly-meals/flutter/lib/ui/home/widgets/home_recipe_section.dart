import 'package:firebase_ai_friendly_meals/core/widgets/bordered_card.dart';
import 'package:firebase_ai_friendly_meals/ui/home/cubit/home_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gpt_markdown/gpt_markdown.dart';

class HomeRecipeSection extends StatelessWidget {
  const HomeRecipeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) => previous.recipe != current.recipe,
      builder: (context, state) {
        if (state.recipe == null) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: BorderedCard(
            child: Column(
              spacing: 16,
              children: [
                // TODO: display recipe image and description
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RecipeDescription extends StatelessWidget {
  const _RecipeDescription({required this.data});

  final String data;

  @override
  Widget build(BuildContext context) {
    return GptMarkdown(
      data,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Colors.black,
      ),
    );
  }
}
