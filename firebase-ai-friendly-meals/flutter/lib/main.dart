import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:myapp/firebase_options.dart';
import 'package:myapp/recipe_generator_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
