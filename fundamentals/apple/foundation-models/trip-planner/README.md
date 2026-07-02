# Adding intelligent app features with generative models

Build robust apps with guided generation and tool calling by adopting the Foundation Models framework.

## Overview

This app showcases the Foundation Models framework and how to build robust apps with guided generation and tool calling, integrating with Google's Gemini models via **Firebase AI Logic**.

For more information about the app and how it works, see
[Adding intelligent app features with generative models](https://developer.apple.com/documentation/foundationmodels/adding-intelligent-app-features-with-generative-models)
in the Apple developer documentation.

---

## Firebase Setup Instructions

To run this sample app, you need to connect it to a Firebase project and configure the required services.

### Step 1: Create a Firebase Project

1. Go to the [Firebase console](https://console.firebase.google.com/).
2. Click **Create a project** (or **Add project**) and follow the setup wizard. You do not need to enable Google Analytics.

### Step 2: Register your iOS App with Firebase

1. In the project overview of the Firebase console, click the **iOS+** icon to launch the setup assistant.
2. Enter your app's **Bundle Identifier**: `com.example.apple-samplecode.FoundationModelsTripPlanner.peterfriese`.
3. Click **Register app**.

### Step 3: Download and Add `GoogleService-Info.plist`

1. Download the `GoogleService-Info.plist` configuration file from the setup assistant.
2. Open `FoundationModelsTripPlanner.xcodeproj` in Xcode.
3. Drag and drop the downloaded `GoogleService-Info.plist` file into the Xcode Project Navigator under `FoundationModelsTripPlanner/FoundationModelsTripPlanner/`.
4. Ensure **Copy items if needed** is checked, and make sure it is added to the **FoundationModelsTripPlanner** target.

### Step 4: Turn on Required Firebase APIs

1. **Enable Firebase AI Logic**:
   - In the Firebase console, navigate to **Build** > **AI Services** > **AI Logic**.
   - Click **Get started** and select the **Gemini Developer API** provider (or your preferred Vertex AI setup).
2. **Configure App Check**:
   - Go to **Security** > **App Check** in the Firebase console.
   - Register your app with your chosen attestation provider (e.g., App Attest for physical devices/production, or the App Check Debug Provider for simulators/local development).
   - In the **APIs** tab, find **Firebase AI Logic** and click **Enforce**.
   
> [!TIP]
> For simulator testing, look at `FoundationModelsTripPlannerApp.swift` where `TripPlannerAppCheckProviderFactory` is configured. If running on a simulator, it will use the `AppCheckDebugProvider`. Check your Xcode debug console on startup to find your local debug token, then register it under **App Check** > **Apps** > **Manage debug tokens** in the Firebase console.
