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

1. **Clone this repository**
   ```sh
   git clone <repo-url>
   ```
2. **Open the project**
   - Open `FriendlyMeals.xcodeproj` in Xcode.

## 🔥 Setting Up Firebase

1. **Create a Firebase Project**
   - Go to the [Firebase Console](https://console.firebase.google.com/).
   - Click **Add project** and follow the prompts.

2. **Register the iOS App**
   - Click **Add app** > **iOS**.
   - Enter the bundle ID: `com.google.firebase.samples.FriendlyMeals`
   - (Optional) Enter an app nickname and App Store ID.
   - Click **Register app**.

3. **Download the `GoogleService-Info.plist`**
   - Download the file from the Firebase Console.
   - Drag and drop it into the `FriendlyMeals/FriendlyMeals` folder in Xcode.
   - Ensure **Copy items if needed** is checked and the file is added to the "FriendlyMeals" target.

4. **Enable Backend Services**
   To make the app fully functional, enable these services in your Firebase Console:
   - **Vertex AI in Firebase**: Required for all AI features. Ensure the "Blaze" (Pay as you go) plan is enabled if required by the models you choose, though many features work on the Spark plan depending on current offerings.
   - **Cloud Firestore**: Create a database. Start in **Test Mode** for quick setup (remember to secure your rules later!).
   - **Remote Config**: Enable Remote Config to manage app behavior dynamically.

5. **Configure Remote Config**
   The app uses two files to manage Remote Config parameters:

   - **`remote_config_defaults.plist`**: This file, located in the Xcode project, contains **in-app default values**. These are used immediately when the app launches, before any values are fetched from the server, or if the device is offline.
   - **`remote_config_template.json`**: This file contains the **server-side configuration**. You can import this template into the Firebase Console to quickly set up all the parameters and their default values on the server.

   **To import the template:**
   1. Go to **Remote Config** in the Firebase Console.
   2. Click on the **menu (three dots)** in the top right corner of the Remote Config dashboard.
   3. Select **Import configurations**.
   4. Upload the `FriendlyMeals/FriendlyMeals/remote_config_template.json` file from this repository.
   5. Review the changes and click **Publish**.

   *Alternatively, if you have the [Firebase CLI](https://firebase.google.com/docs/cli) installed, you can run:*
   ```bash
   firebase remoteconfig:get --version-number 1  # Backup existing config if needed
   firebase remoteconfig:versions:list           # Check current versions
   firebase remoteconfig:rollback <version>      # Rollback if needed
   # To deploy the template:
   firebase remoteconfig:deploy --template remote_config_template.json
   ```

6. **Run the App**
   - Build and run in Xcode on a simulator or device.

## 🤝 Contributing

Contributions and suggestions are welcome! Feel free to open issues or pull requests as you follow along with the series.

## 📄 License

This project is licensed under the [Apache License](./LICENSE), which can be found in the root of this repository. It is provided for educational purposes as part of the Firebase Fundamentals video series.