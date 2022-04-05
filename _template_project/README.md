# Firebase Fundamentals: Getting Started with Firebase Authentication on the Web

This is the source code used in this video: [Getting started with Firebase Authentication on the web](https://youtu.be/rbuSx1yEgV8).

## Prerequisites

* Install the Firebase CLI tools and the Firebase Emulator suite ([instructions](https://firebase.google.com/docs/emulator-suite/install_and_configure))

## How to use

1. Clone the repository
2. Navigate into the root folder of this project
3. Install the dependencies

    ```bash
    $ npm install
    ```

4.  Run webpack to bundle your code:

    ```bash
    $ npx webpack
    ```

5. Run the Firebase Emulator to host your app locally:

    ```bash
    $ firebase emulators:start
    ```

6. Open `http://localhost:5001` in your browser
  ![](images/login.png)
7. Sign up using an email address and password of your choice (e.g. `me@awesomekittens.test`)
8. You should now be signed in
  ![](images/loggedin.png)
9. Navigate to `http://localhost:4000/auth` to see the newly created user in the Firebase Authentication Emulator UI
  ![](images/auth_emulator_ui.png)
10. Go back to the app, and sign out
11. Sign in using the credentials you used to create the test account