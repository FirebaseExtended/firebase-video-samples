import 'package:firebase_ai_friendly_meals/core/widgets/error_banner.dart';
import 'package:firebase_ai_friendly_meals/ui/home/cubit/home_cubit.dart';
import 'package:firebase_ai_friendly_meals/ui/home/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(),
      child: const _HomeScreen(),
    );
  }
}

class _HomeScreen extends StatefulWidget {
  const _HomeScreen();

  @override
  State<_HomeScreen> createState() => __HomeScreenState();
}

class __HomeScreenState extends State<_HomeScreen> {
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _ingredientsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HomeIngredientsBox(
                ingredientsController: _ingredientsController,
                notesController: _notesController,
              ),
              BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state.status.isFailure && state.errorMessage != null) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: ErrorBanner(
                        message: state.errorMessage!,
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
              const HomeRecipeSection(),
            ],
          ),
        ),
      ),
    );
  }
}
