# Firebase AI Friendly Meals - Flutter

An AI-powered meal preparation app built with Flutter, Firebase AI, and modern architecture patterns.

## Features

- 📸 **Image Analysis**: Take photos or select images of food ingredients
- 🤖 **AI-Powered Ingredient Recognition**: Use Gemini to identify ingredients from images
- 🍳 **Recipe Generation**: Generate recipes based on identified ingredients and user notes
- 🎨 **Recipe Image Creation**: Generate professional food photography with Imagen
- 📱 **Modern UI**: Clean, Material 3 design with responsive layout

## Architecture

This Flutter app follows modern architectural patterns:

### **Data Layer**

```
lib/data/
├── datasource/
│   └── ai_remote_data_source.dart     # AI API calls (Gemini & Imagen)
├── repository/
│   └── ai_repository.dart             # Repository pattern implementation
└── model/
    └── recipe.dart                    # Recipe data model
```

### **UI Layer**

```
lib/ui/
└── home/
    ├── home_page.dart                 # Main UI screen
    ├── cubit/
    │   ├── home_cubit.dart            # State management (BLoC/Cubit)
    │   └── home_state.dart            # UI state definitions
    └── widgets/
        ├── home_ingredients_section.dart
        ├── home_recipe_section.dart
        └── widgets.dart
```

### **Core Infrastructure**

```
lib/core/
├── di/
│   └── firebase_module.dart           # DI for Firebase AI models
├── exceptions/
│   └── ai_exceptions.dart             # Custom exception classes
├── theme/                             # App theming
└── widgets/                           # Reusable UI components
```

## Tech Stack

### **Core Framework**

- **Flutter**: Cross-platform UI framework
- **Dart**: Programming language

### **State Management & Architecture**

- **BLoC/Cubit**: State management pattern (`flutter_bloc`)
- **Equatable**: Value equality for state classes
- **GetIt**: Service locator for dependency injection
- **Injectable**: Code generation for DI

### **Firebase & AI**

- **Firebase Core**: Firebase initialization
- **Firebase AI**: Gemini and Imagen model access
- **Firebase App Check**: App verification and security
- **Image Picker**: Camera and gallery integration

### **UI & Design**

- **Material 3**: Modern Material Design
- **GPT Markdown**: Recipe content formatting
- **Cupertino Icons**: iOS-style icons

## Getting Started

### Prerequisites

1. **Flutter SDK** (3.8.0 or later)
2. **Firebase Project** with AI Logic enabled
3. **Firebase AI API access** (Gemini Developer API or Vertex AI)

### Setup

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd firebase_ai_friendly_meals
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Generate dependency injection code**

   ```bash
   dart run build_runner build
   ```

4. **Configure Firebase**

   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Enable Firebase AI Logic in your Firebase project
   - Set up API keys for Gemini and Imagen models

5. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure Details

### **Key Components**

#### **AIRemoteDataSource**

Handles direct API calls to Firebase AI services:

- `generateIngredients()`: Multimodal Gemini call with image input
- `generateRecipe()`: Text generation based on ingredients and notes
- `generateRecipeImage()`: Imagen model for recipe photography

#### **AIRepository**

Provides a clean interface for the UI layer, abstracting the data source implementation.

#### **HomeCubit (State Management)**

Manages the home screen state using BLoC pattern:

- Image selection and preview
- Ingredient loading states
- Recipe generation workflow
- Error handling and validation

#### **HomeState**

Immutable state class containing:

- `ingredients`: Current ingredient list
- `notes`: User-provided cooking notes
- `selectedImage`: Selected image for analysis
- `recipe`: Generated recipe result
- `status`: Current view state (initial, loading, success, failure)
- `errorMessage`: Error messages for user feedback

#### **HomePage (UI)**

Responsive UI with sections for:

- Image capture/selection
- Ingredients display
- Notes input
- Recipe generation
- Results display

### **Firebase AI Integration**

The app uses Firebase AI Logic to access:

- **Gemini Models**: For text generation and multimodal analysis
- **Imagen Models**: For high-quality recipe image generation

```dart
// Example Gemini call
final response = await _generativeModel.generateContent([
  Content.text(prompt)
]);

// Example Imagen call
final imageResponse = await _imagenModel.generateImages(prompt);
```

## Development Workflow

### **Code Generation**

Some features require code generation:

```bash
# Generate dependency injection code
dart run build_runner build

# Watch for changes during development
dart run build_runner watch
```

## Next Steps

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is part of the Firebase Extended samples and follows the same licensing terms.

---

**Built with ❤️ using Flutter and Firebase AI Logic**
