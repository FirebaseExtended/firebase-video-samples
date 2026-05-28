# MakeItSo

MakeItSo is a cross-platform task and list-sharing application built to demonstrate modern mobile development workflows with Firebase. The project consists of native client applications for both iOS (Swift/SwiftUI) and Android (Kotlin/Jetpack Compose), backed by Cloud Firestore and Firebase Authentication.

---

## 🛠️ Environment Configuration

To keep the codebase maintainable across development, staging, and production environments, all deep link sharing URLs are constructed dynamically at runtime.

### iOS Configuration
Rather than hard-coding the URL prefix, the iOS application dynamically extracts the Firebase Project ID from the loaded runtime configurations:
```swift
FirebaseApp.app()?.options.projectID
```
It then constructs the sharing link dynamically:
```swift
"https://\(projectId).web.app/join/\(listId)?token=\(token)"
```
This ensures that swapping the `GoogleService-Info.plist` configuration file automatically updates the generated deep links without requiring any code modifications.

---

## 🔗 Deep Link & List Sharing Workflows

The application supports real-time list sharing and collaboration via deep links. Testing these links inside mobile emulators requires specific considerations due to sandbox restrictions and operating system security policies.

### 📱 iOS Simulator Deep Link Testing

When sharing lists on the iOS Simulator, the system Share Sheet behaves differently than on a physical device.

#### Simulator Clipboard Sync Issue
If you share a structured `URL` object and select the **"Copy"** action in the Simulator Share Sheet, the system may only copy the message description or fail to synchronize the rich URL metadata across the Simulator pasteboard to the host macOS clipboard (often producing a warning sound or beep on your Mac).

To resolve this, `ShareLink` is configured to share the deep link as a plain text `String`:
```swift
ShareLink(item: url.absoluteString)
```
This forces the Simulator to copy the link as a plain string, which synchronizes instantly and flawlessly with the host macOS clipboard, letting you paste it directly into your Mac editor.

#### CLI Testing Command
To trigger the deep link directly on a running iOS Simulator, use the following `xcrun` command:
```bash
xcrun simctl openurl booted "https://<your-project-id>.web.app/join/<list-id>?token=<share-token>"
```

---

### 🤖 Android Emulator App Links Testing

Starting with Android 12, the operating system requires strict domain verification for all App Links (`https` schemes). 

#### Debug Build Verification Bypass
When running local developer debug builds, the application is signed with a local debug keystore. Since its signing fingerprint does not match the fingerprint of the Digital Asset Links configuration file (`/.well-known/assetlinks.json`) deployed on the live Firebase Hosting site, the Android operating system will fail verification and fall back to opening all deep links in **Chrome** instead of your app.

To bypass this restriction and force the Android Emulator to route the deep link to the application:

1. **Force Association Command:**
   Run the following `adb` shell command to manually approve the domain association for the debug package:
   ```bash
   adb shell pm set-app-links --package com.google.firebase.example.makeitso 2 make-it-so-live-ccdr-01.web.app
   ```
   *(Setting the state to `2` marks the package association as `approved`, forcing the system to always route supported domains to the app.)*

2. **Verify Association Status:**
   To confirm that the domain association was successfully approved:
   ```bash
   adb shell pm get-app-links com.google.firebase.example.makeitso
   ```
   The domain `make-it-so-live-ccdr-01.web.app` should now display as `approved`.

3. **CLI Testing Command:**
   With the domain approved, you can launch the deep link intent directly to the emulator, which will bypass Chrome and launch the MakeItSo app:
   ```bash
   adb shell am start -W -a android.intent.action.VIEW -d "https://make-it-so-live-ccdr-01.web.app/join/<list-id>?token=<share-token>"
   ```

---

## 🎨 Real-Time UI Synchronization

In SwiftUI, views within dynamic loops (like `ForEach`) rely on the `Identifiable` and `Equatable` protocols to optimize redraws. 

To ensure that changes to list properties (such as renaming a list in the Firebase Console) are updated in the UI in real-time, `TaskList` relies on compiler-synthesized memberwise comparisons. Avoid overriding `==` or `hash(into:)` to compare only the `id` property, as doing so prevents SwiftUI from detecting updates to other properties like the list `title` when the local database updates.
