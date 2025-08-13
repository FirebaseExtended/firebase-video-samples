import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class RecipeGeneratorScreen extends StatefulWidget {
  const RecipeGeneratorScreen({super.key});

  @override
  State<RecipeGeneratorScreen> createState() => _RecipeGeneratorScreenState();
}

class _RecipeGeneratorScreenState extends State<RecipeGeneratorScreen> {
  final _ingredientsController = TextEditingController();
  final _notesController = TextEditingController();
  bool _showRecipeCard = false;
  String _generatedRecipe = "";
  bool _isLoading = false;

  void _handleGenerateRecipe() async {
    if (_ingredientsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter some ingredients.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() {
      _isLoading = true;
      _showRecipeCard = false;
    });

    try {
      final model = FirebaseAI.googleAI().generativeModel(
        model: 'gemini-2.5-flash-lite',
      );

      final ingredients = _ingredientsController.text;
      final notes = _notesController.text;
      String prompt =
          "Based on this list of ingredients: $ingredients, please give me a recipe. ";
      if (notes.isNotEmpty) {
        prompt += "Please also take in consideration these notes: $notes";
      }
      final response = await model.generateContent([Content.text(prompt)]);

      setState(() {
        _generatedRecipe = response.text ?? 'No recipe generated.';
        _showRecipeCard = true;
      });
    } catch (e) {
      setState(() {
        _generatedRecipe = 'Error generating recipe: $e';
        _showRecipeCard = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
              TextField(
                controller: _ingredientsController,
                decoration: const InputDecoration(
                  labelText: 'Enter ingredients (comma separated)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes or preferred cuisines',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32.0),
              TextButton(
                onPressed: _isLoading ? null : _handleGenerateRecipe,
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: const TextStyle(fontSize: 18.0),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text('Generate Recipe'),
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
