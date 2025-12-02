# FriendlyMeals – Firebase Fundamentals iOS Samples

Welcome to **FriendlyMeals**, a sample iOS project accompanying the [Firebase Fundamentals video series](https://www.youtube.com/playlist?list=PLl-K7zZEsYLnfwBe4WgEw9ao0J0N1LYDR) on YouTube.

![App Screenshot](assets/screenshot-hero.png)
*FriendlyMeals app – Hero screenshot with gradient background*

This repository demonstrates how to integrate Firebase features into an iOS app, with a strong focus on **Firebase AI Logic** (Vertex AI in Firebase), **Cloud Firestore**, and **Remote Config**.

## 📺 Video Series

- [Firebase Fundamentals on YouTube](https://www.youtube.com/playlist?list=PLl-K7zZEsYLnfwBe4WgEw9ao0J0N1LYDR)

## 🚀 Features

### 🧠 AI-Powered Features (Firebase AI Logic)
- **Nutrition Detective**: Take a photo of a meal, and the app uses multimodal generative AI (Gemini) to analyze its nutritional content (calories, protein, fats, carbs) and explain its reasoning stream-by-stream.
- **Recipe Wizard**: Suggests complete recipes based on ingredients you have. It uses structured output (JSON mode) for reliable data parsing and can generate visual previews of the dish using image generation models.
- **Chef Chat**: An interactive meal planner chat with a "spicy celebrity chef" persona. It demonstrates **Function Calling** capabilities by allowing the AI to start and manage cooking timers within the app.

### ☁️ Cloud Features
- **Cookbook (Firestore)**: Save, view, and manage your favorite recipes. Data is persisted securely using **Cloud Firestore**.
- **Dynamic Settings (Remote Config)**: The app allows you to change behavior on the fly—such as the maximum number of daily image generations or the specific AI model version—using **Firebase Remote Config**, without needing an App Store update.

## 🏗️ Project Structure

The project is organized by feature, keeping related SwiftUI Views, ViewModels, and logic together:

```
FriendlyMeals/
  └── FriendlyMeals/
      └── Features/
          ├── Camera/           # Camera integration for nutrition scanning
          ├── Cookbook/         # Firestore-backed recipe list
          ├── DetectNutrition/  # Multimodal AI analysis of food photos
          ├── MealPlannerChat/  # AI Chat with Function Calling (Timers)
          ├── Services/         # Core services (RecipeService, RemoteConfigService)
          └── SuggestRecipe/    # AI Recipe generation (Text & Image)
```

## 🛠️ Getting Started

Follow these steps to get the app running on your machine.

### 1. Clone the repository

```sh
git clone <repo-url>
```

### 2. Set up a Firebase Project

1.  Go to the [Firebase Console](https://console.firebase.google.com/).
2.  Click **Add project** and follow the prompts.

### 3. Register the iOS App

1.  In the Firebase Console, click **Add app** > **iOS**.
2.  Enter the bundle ID: `com.google.firebase.samples.FriendlyMeals`
3.  (Optional) Enter an app nickname and App Store ID.
4.  Click **Register app**.

### 4. Configure `GoogleService-Info.plist`

1.  Download the `GoogleService-Info.plist` file from the Firebase Console.
2.  Open `FriendlyMeals.xcodeproj` in Xcode.
3.  Drag and drop the downloaded file into the `FriendlyMeals/FriendlyMeals` folder in the Xcode Project Navigator.
4.  **Important:** Ensure **Copy items if needed** is checked and the file is added to the "FriendlyMeals" target.

### 5. Enable Backend Services

To make the app fully functional, enable these services in your Firebase Console:

*   **Vertex AI in Firebase**: Required for all AI features.
    *   *Note: Ensure the "Blaze" (Pay as you go) plan is enabled if required by the models you choose.*
*   **Cloud Firestore**: Create a database. Start in **Test Mode** for quick setup (remember to secure your rules later!).
*   **Remote Config**: Enable Remote Config to manage app behavior dynamically.

### 6. Configure Remote Config

The app uses two files to manage Remote Config parameters:

*   **`remote_config_defaults.plist`**: This file (already in the Xcode project) contains **in-app default values**. These are used immediately when the app launches.
*   **`remote_config_template.json`**: This file contains the **server-side configuration**.

**Option A: Import via Console (Recommended)**
1.  Go to **Remote Config** in the Firebase Console.
2.  Click on the **menu (three dots)** in the top right corner of the Remote Config dashboard.
3.  Select **Import configurations**.
4.  Upload the `FriendlyMeals/FriendlyMeals/remote_config_template.json` file from this repository.
5.  Review the changes and click **Publish**.

**Option B: Use Firebase CLI**
If you have the [Firebase CLI](https://firebase.google.com/docs/cli) installed and initialized, you can publish the template directly:

```bash
firebase remoteconfig:publish FriendlyMeals/FriendlyMeals/remote_config_template.json
```

### 7. Run the App

1.  Select a simulator or connected device in Xcode.
2.  Build and run the project (`Cmd + R`).

## 🤝 Contributing

Contributions and suggestions are welcome! Feel free to open issues or pull requests as you follow along with the series.

## 📄 License

This project is licensed under the [Apache License](./LICENSE), which can be found in the root of this repository. It is provided for educational purposes as part of the Firebase Fundamentals video series.
