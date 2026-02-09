---
name: firebase-swift-best-practices
description: Expert patterns for Firebase (Auth, Firestore, Cloud Functions) using modern Swift Concurrency (Actors, Async/Await) and Observation (@Observable).
---

# Firebase Swift Best Practices Skill

## Overview
Use this skill to implement robust, thread-safe, and performant Firebase integrations in modern Swift applications. This skill focuses on the intersection of Firebase SDKs and modern Swift features like `@Observable`, `async/await`, and Actor isolation.

## Workflow Decision Tree

### 1) Implementing a New Repository
- Use the **Surgical Actor Isolation** pattern to prevent `deinit` conflicts (see `references/concurrency.md`)
- Use `@Observable` for the repository class (see `references/concurrency.md`)
- Implement real-time listeners with proper lifecycle management (see `references/firestore.md`)

### 2) Handling Authentication
- Bridge Firebase Auth state to SwiftUI using `@Observable` (see `references/auth.md`)
- Use `async/await` for sign-in and sign-out operations (see `references/auth.md`)

### 3) Data Operations
- Use `Codable` support in Firestore for type-safe data handling (see `references/firestore.md`)
- Use native `async/await` for all single-result operations like `getDocuments`, `addDocument`, and `setData` (see `references/concurrency.md`)
- For continuous data streams, bridge listeners to `AsyncStream` (see `references/concurrency.md`)

## Core Guidelines

### Concurrency & Isolation
- **Prefer surgical isolation**: While class-level `@MainActor` is generally recommended for simplicity, we prefer surgical isolation for Firebase repositories to allow non-isolated cleanup in `deinit`. On Swift 6.2+ (SE-0371), you can alternatively use class-level `@MainActor` with an `isolated deinit`.
- **Always clean up**: Always remove `AuthStateListener` and `ListenerRegistration` in `deinit`.
- **Bridge to MainActor**: When receiving results from Firebase background closures, use `Task { @MainActor in ... }` to update `@Observable` properties.

### Firestore
- Use `@DocumentID` for mapping Firestore document IDs to model properties.
- Use `@ServerTimestamp` for managing creation/update dates.
- Order queries explicitly when using real-time listeners to maintain UI stability.

### Authentication
- Check for `currentUser` before triggering anonymous sign-in to avoid redundant sessions.
- Use `weak self` in Auth state listeners to prevent retain cycles.

## References
- `references/concurrency.md`: Surgical actor isolation and async bridging.
- `references/firestore.md`: Real-time listeners, CRUD, and Codable patterns.
- `references/auth.md`: Authentication state management and async flows.

## External References
- [Firebase Documentation](https://firebase.google.com/docs/ios/setup)
- [Swift Evolution SE-0371](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0371-isolated-synchronous-deinit.md)
- [Matt Massicotte's Blog](https://www.massicotte.org) (Swift Concurrency Expert)
