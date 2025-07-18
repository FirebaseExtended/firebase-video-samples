import 'package:flutter/material.dart';
import 'package:myapp/recipe_generator_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Friendly Meals',
      theme: ThemeData(
        primaryColor: const Color(0xFFFFC400),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFC400)),
      ),
      home: const RecipeGeneratorScreen(),
    );
  }
}

