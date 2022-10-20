# Firebase Fundamentals: Getting started with Firebase Auth for Apple platforms

This is the source code used in this video: [Getting started with Firebase Auth for Apple platforms](https://www.youtube.com/watch?v=q-9lx7aSWcc).

## Prerequisites

* Install the Firebase CLI tools and the Firebase Emulator suite ([instructions](https://firebase.google.com/docs/emulator-suite/install_and_configure))

## How to use

1. Clone the repository
2. Navigate into the `final` folder for this project

    ```bash
    $ cd fundamentals/apple/auth-gettingstarted/final/Favourites
    ```

3. Open the project in Xcode

    ```bash
    $ xed .
    ```

4. Run the Firebase Authentication Emulator locally:

    ```bash
    $ firebase emulators:start
    ```

5. Run the app on the iOS Simulator
6. On the login screen, switch to the sign-up screen, and sign up using email and password
7. Once you are signed in, you can see the newly created user account in the Firebase Authentication Emulator (http://localhost:4000/auth)