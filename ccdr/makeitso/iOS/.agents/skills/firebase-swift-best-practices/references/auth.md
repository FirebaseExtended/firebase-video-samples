# Authentication Best Practices

## Bridging Auth State to @Observable
Provide a reactive way for the UI to respond to user sign-in/sign-out events.

```swift
@Observable
class Repository {
  @MainActor var user: User?
  private var authHandle: AuthStateDidChangeListenerHandle?

  init() {
    authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
      Task { @MainActor in
        self?.user = user
        if let user = user {
          self?.subscribe(userId: user.uid)
        } else {
          self?.unsubscribe()
        }
      }
    }
  }

  deinit {
    if let handle = authHandle {
      Auth.auth().removeStateDidChangeListener(handle)
    }
  }
}
```

## Anonymous Sign-In
Use anonymous sign-in to provide a seamless "first run" experience. Always check if a user is already signed in.

```swift
func signIn() {
  if Auth.auth().currentUser == nil {
    Auth.auth().signInAnonymously { ... }
  }
}
```

## Retain Cycles
Always use `[weak self]` in the `addStateDidChangeListener` closure, as the `Auth` singleton will persist and could keep your repository instance alive even after it's been dismissed from the UI.
