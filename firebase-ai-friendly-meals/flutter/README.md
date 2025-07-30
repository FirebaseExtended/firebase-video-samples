# Firebase AI Friendly Meals Workshop

## Google AI Studio

A web playground that lets you quickly experiment with Google's AI models
[Google AI Studio](https://aistudio.google.com)

```
Based on this ingredients list:
[TYPE YOUR LIST OF INGREDIENTS],
please give me one recipe. Please take in consideration these notes:
[TYPE YOUR NOTES, LIKE DIETARY RESTRICTIONS AND CUISINE PREFERENCES]
```

## Prerequisites

Before starting this workshop, make sure you have the following installed:

- **Flutter 3.32.8** or later
  - You can check your Flutter version by running: `flutter --version`
  - To upgrade Flutter, run: `flutter upgrade`
- **Dart SDK** (included with Flutter)
- **Android Studio** or **Xcode** (for running on mobile devices)
- **VS Code** or your preferred IDE with Flutter extension

## Setting up your environment

1. Clone the repository:

   ```bash
   git clone https://github.com/bgoktugozdemir-dev/firebase_ai_friendly_meals.git
   ```

2. Checkout the workshop branch:

   ```bash
   git checkout workshop
   ```

3. Open the `firebase_ai_friendly_meals` folder in an IDE _(VSCode, Intellij, Android Studio)_.

4. Open the [Firebase console](https://console.firebase.google.com).

5. Click on **Create a Firebase project**, and then follow the on-screen instructions.

## Configuring Firebase with Flutter

1. If you haven't already, install the [Firebase CLI](https://firebase.google.com/docs/cli#setup_update_cli).

2. Log into Firebase using your Google account by running the following command:

   ```bash
   firebase login
   ```

3. Install the FlutterFire CLI by running the following command from any directory:

   ```bash
   dart pub global activate flutterfire_cli
   ```

4. Use the FlutterFire CLI to configure your Flutter apps to connect to Firebase:

   ```bash
   flutterfire configure
   ```

## Creating the model instance

In the [`firebase_module.dart`](lib/core/di/firebase_module.dart) file:

1. Update the `_googleAI` getter.

   Change this:

   ```dart
   @preResolve
   @singleton
   // TODO: Creating the Google AI instance
   FirebaseAI get _googleAI => throw UnimplementedError();
   ```

   To this:

   ```dart
   @preResolve
   @singleton
   FirebaseAI get _googleAI => FirebaseAI.googleAI();
   ```

2. Update the `provideGenerativeModel()` method.

   Change this:

   ```dart
   @singleton
   GenerativeModel provideGenerativeModel() {
    // TODO: Creating the generative model instance
    throw UnimplementedError();
   }
   ```

   To this:

   ```dart
   @singleton
   GenerativeModel provideGenerativeModel() {
    const model = 'gemini-2.0-flash';

    return _googleAI.generativeModel(
      model: model,
    );
   }
   ```

3. Update the `provideImagenModel()` method.

   Change this:

   ```dart
   @singleton
   ImagenModel provideImagenModel() {
    // TODO: Creating the imagen model instance
    throw UnimplementedError();
   }
   ```

   To this:

   ```dart
   @singleton
   ImagenModel provideImagenModel() {
    const model = 'imagen-3.0-generate-002';

    final generationConfig = ImagenGenerationConfig(
      numberOfImages: 1,
      aspectRatio: ImagenAspectRatio.square1x1,
      imageFormat: ImagenFormat.png(),
    );

    final safetySettings = ImagenSafetySettings(
      ImagenSafetyFilterLevel.blockLowAndAbove,
      ImagenPersonFilterLevel.blockAll,
    );

    return _googleAI.imagenModel(
      model: model,
      generationConfig: generationConfig,
      safetySettings: safetySettings,
    );
   }
   ```

## Preparing the UI

### 1. HomeIngredientsSection

In the [`home_ingredients_section.dart`](lib/ui/home/widgets/home_ingredients_section.dart) file, implement the `onGenerateRecipe` logic.

Change this:

```dart
class _GenerateButton extends StatelessWidget {
  // other UI elements
  void _onPressed(BuildContext context) {
    // TODO: Implement the generate recipe logic
  }
}
```

To this:

```dart
class _GenerateButton extends StatelessWidget {
  // other UI elements
  void _onPressed(BuildContext context) {
    context.read<HomeCubit>().onGenerateRecipe();
  }
}
```

### 2. HomeRecipeSection

In the [`home_recipe_section.dart`](lib/ui/home/widgets/home_recipe_section.dart) file, display `MemoryImageBuilder` and `_RecipeDescription` widgets.

Change this:

```dart
class HomeRecipeSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // other UI elements
    return BorderedCard(
      child: Column(
        spacing: 16,
        children: [
          // TODO: display recipe image and description
        ],
      ),
    );
  }
}
```

To this:

```dart
class HomeRecipeSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // other UI elements
    return BorderedCard(
      child: Column(
        spacing: 16,
        children: [
          if (state.recipe?.image case final image?)
            MemoryImageBuilder(imageBytes: image),
          if (state.recipe?.description case final description?)
            _RecipeDescription(data: description),
        ],
      ),
    );
  }
}
```

## Implementing the business logic

In the [`home_cubit.dart`](lib/ui/home/cubit/home_cubit.dart) file, call the `generateRecipe()` and `generateRecipeImage()` from `_aiRepository`.

Change this:

```dart
class HomeCubit extends Cubit<HomeState> {
  Future<void> onGenerateRecipe() async {
    // TODO: Call the repository to generate the recipe
  }
}
```

To this:

```dart
class HomeCubit extends Cubit<HomeState> {
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

    try {
      final recipeDescription = await _aiRepository.generateRecipe(
        state.ingredients,
        state.notes,
      );

      final recipeImage = await _aiRepository.generateRecipeImage(
        recipeDescription,
      );

      final recipe = Recipe(
        description: recipeDescription,
        image: recipeImage,
      );
      emit(
        state.copyWith(
          recipe: () => recipe,
          status: HomeViewState.success,
          errorMessage: () => null,
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
}
```

## Implementing the data layer

In the [`ai_remote_data_source.dart`](lib/data/datasource/ai_remote_data_source.dart) file:

1. Update the `generateIngredients()` method.

   Change this:

   ```dart
   Future<String> generateIngredients(Uint8List image) async {
    // TODO: Call generative model with multimodal prompt to extract ingredients from image
    return '';
   }
   ```

   To this:

   ```dart
   Future<String> generateIngredients(Uint8List image) async {
    if (image.isEmpty) {
      throw const ValidationException('Image data is empty');
    }

    const prompt =
        "Please analyze this image and list all visible food ingredients. "
        "Format the response as a comma-separated list of ingredients. "
        "Be specific with measurements where possible, "
        "but focus on identifying the ingredients accurately.";

    try {
      final response = await _generativeModel.generateContent([
        Content.multi(
          [
            InlineDataPart('image/png', image),
            TextPart(prompt),
          ],
        ),
      ]);

      if (response.text == null || response.text!.trim().isEmpty) {
        throw const ImageAnalysisException(
          'Failed to analyze image - no ingredients detected',
        );
      }

      return response.text!;
    } catch (e) {
      if (e is AIException) {
        rethrow;
      }
      throw ImageAnalysisException(
        'Failed to generate ingredients: $e',
      );
    }
   }
   ```

2. Update the `generateRecipe()` method.

   Change this:

   ```dart
   Future<String> generateRecipe(String ingredients, String notes) async {
    // TODO: call generative model to generate recipe
    return '';
   }
   ```

   To this:

   ```dart
   Future<String> generateRecipe(String ingredients, String notes) async {
    if (ingredients.trim().isEmpty) {
      throw const ValidationException('Ingredients list cannot be empty');
    }

    String prompt =
        "Based on this ingredients list: $ingredients, please give me one recipe.";
    if (notes.isNotEmpty) {
      prompt += " Please take into consideration these notes: $notes.";
    }

    try {
      final response = await _generativeModel.generateContent([
        Content.text(prompt),
      ]);

      if (response.text == null || response.text!.trim().isEmpty) {
        throw const AIGenerationException(
          'Failed to generate recipe - empty response',
        );
      }

      return response.text!;
    } catch (e) {
      if (e is AIException) {
        rethrow;
      }
      throw AIGenerationException('Failed to generate recipe: $e');
    }
   }
   ```

3. Update the `generateRecipeImage()` method.

   Change this:

   ```dart
   Future<Uint8List> generateRecipeImage(String recipe) async {
    // TODO: Call Imagen model to generate recipe photo
    return Uint8List(0);
   }
   ```

   To this:

   ```dart
   Future<Uint8List> generateRecipeImage(String recipe) async {
    if (recipe.trim().isEmpty) {
      throw const ValidationException('Recipe description cannot be empty');
    }

    final prompt =
        "A professional food photography shot of this recipe: $recipe. "
        "Style: High-end food photography, restaurant-quality plating, soft natural "
        "lighting, on a clean background, showing the complete plated dish.";

    try {
      final imageResponse = await _imagenModel.generateImages(prompt);
      final images = imageResponse.images;

      if (images.isEmpty) {
        throw const AIGenerationException(
          'Failed to generate recipe image - no images returned',
        );
      }

      return images.first.bytesBase64Encoded;
    } catch (e) {
      if (e is AIException) {
        rethrow;
      }
      throw AIGenerationException(
        'Failed to generate recipe image: $e',
      );
    }
   }
   ```

## Activating AppCheck

1. Open the [Firebase console](https://console.firebase.google.com). Choose your project. Click **Build** > **App Check**

2. To activate App Check, click on **Get Started**

3. For production, register apps.

4. Add [`firebase_app_check`](https://pub.dev/packages/firebase_app_check) package to the `dependencies` in the [`pubspec.yaml`](pubspec.yaml) file.

   ```yaml
   dependencies:
     firebase_core: ^3.15.0
     firebase_ai: ^2.2.0
     firebase_app_check: ^0.3.2+8
   ```

5. In the [`main.dart`](lib/main.dart) file:

   Change this:

   ```dart
    void main() async {
        WidgetsFlutterBinding.ensureInitialized();

        await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
        );
        // TODO: Activate Firebase App Check
        configureDependencies();

        runApp(const MyApp());
    }
   ```

   To this:

   ```dart
    void main() async {
        WidgetsFlutterBinding.ensureInitialized();

        await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
        );
        await FirebaseAppCheck.instance.activate(
            androidProvider: AndroidProvider.debug,
            appleProvider: AppleProvider.debug,
        );
        configureDependencies();

        runApp(const MyApp());
    }
   ```

## Applying AppCheck to Firebase AI Logic

In the [`firebase_module.dart`](lib/core/di/firebase_module.dart) file, update the `_googleAI` getter to use AppCheck.

Change this:

```dart
@preResolve
@singleton
FirebaseAI get _googleAI => FirebaseAI.googleAI();
```

To this:

```dart
@preResolve
@singleton
FirebaseAI get _googleAI => FirebaseAI.googleAI(
    appCheck: FirebaseAppCheck.instance,
);
```
