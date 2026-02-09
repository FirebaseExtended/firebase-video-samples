# Concurrency & Actor Isolation

## Surgical Actor Isolation Pattern

This pattern solves the conflict between `@MainActor` class isolation and the requirement that `deinit` must be non-isolated.

### The Problem
While it is generally recommended to mark `@Observable` classes with `@MainActor` for total thread safety, this creates a conflict with `deinit`.

If a class is marked `@MainActor`, all its properties and methods are isolated to the main actor. However, `deinit` is inherently non-isolated. Attempting to access or clean up isolated properties (like a Firestore `ListenerRegistration`) in `deinit` will cause a compiler error.

### The Solution: Surgical Isolation
Apply `@MainActor` surgically to only the parts of the class that require it.

```swift
@Observable
class Repository {
  // 1. Isolate UI-facing properties
  @MainActor var items = [Item]()
  
  // 2. Keep the class itself non-isolated
  private var listener: ListenerRegistration?

  // 3. Isolate mutation methods
  @MainActor func updateItem(_ item: Item) { ... }

  deinit {
    // 4. Safe to access non-isolated listener here
    listener?.remove()
  }
}
```

### The Solution: Modern Approach (Swift 6.2+)
In Swift 6.2+ (SE-0371), you can mark a class with `@MainActor` and use an `isolated deinit` to safely clean up isolated resources.

```swift
@MainActor
@Observable
class ModernRepository {
  var items = [Item]() // Isolated by default
  private var listener: ListenerRegistration?

  isolated deinit {
    // Now safe to access isolated listener because deinit is isolated
    listener?.remove()
  }
}
```
> [!TIP]
> Use Surgical Isolation if you need to support older Swift versions. Use `isolated deinit` on Swift 6.2+ (SE-0371) for a cleaner, class-wide isolation model.

## Handling Background Callbacks
Firebase listeners often return results on a background thread. Always bridge back to the `@MainActor` when updating observed properties.

```swift
listener = query.addSnapshotListener { snapshot, error in
  // Process data on background...
  let items = process(snapshot)
  
  // Bridge back to UI thread
  Task { @MainActor in
    self.items = items
  }
}
```

## Using Native Async/Await
Firestore, Auth, and Storage provide native `async` methods for single-result operations (CRUD). Always prefer these over manual bridging.

```swift
func fetchData() async throws -> [Item] {
  let snapshot = try await db.collection("items").getDocuments()
  return snapshot.documents.compactMap { try? $0.data(as: Item.self) }
}
```

## Real-time Streams with AsyncStream
For continuous updates, use `AsyncThrowingStream` to bridge Firestore's listener to `for await` loops.

> [!NOTE]
> The Firebase team is actively working on bringing native `AsyncSequence` and `AsyncStream` support to the SDK. In a future version, manual bridging with `AsyncThrowingStream` will no longer be necessary.

```swift
func streamItems() -> AsyncThrowingStream<[Item], Error> {
  AsyncThrowingStream { continuation in
    let listener = db.collection("items").addSnapshotListener { snapshot, error in
      if let error = error {
        continuation.finish(throwing: error)
      } else if let snapshot = snapshot {
        let items = snapshot.documents.compactMap { try? $0.data(as: Item.self) }
        continuation.yield(items)
      }
    }
    continuation.onTermination = { _ in
      listener.remove()
    }
  }
}
```

## Legacy or Custom Bridging
If you encounter a legacy API or a custom flow that does not yet support `async/await`, use `withCheckedContinuation`.
```swift
func fetchData() async throws -> [Item] {
  try await withCheckedThrowingContinuation { continuation in
    db.collection("items").getDocuments { snapshot, error in
      if let error = error {
        continuation.resume(throwing: error)
      } else {
        continuation.resume(returning: process(snapshot))
      }
    }
  }
}
```

## Further Reading
- [Matt Massicotte's Blog](https://www.massicotte.org) - A primary resource for Swift Concurrency best practices.
- [SE-0371: Isolated synchronous deinitializers](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0371-isolated-synchronous-deinit.md) - The proposal that introduced the modern cleanup pattern.
- [(No) MainActor by Default](https://www.massicotte.org/no-mainactor-by-default) - Matt's analysis of isolation patterns and why surgical/default decisions matter.
