# Firestore Best Practices

## Real-time Listeners

### Lifecycle Management
Always store the `ListenerRegistration` and remove it in `deinit` to prevent memory leaks and unnecessary data usage.

```swift
private var listener: ListenerRegistration?

func subscribe() {
  guard listener == nil else { return }
  listener = query.addSnapshotListener { ... }
}

func unsubscribe() {
  listener?.remove()
  listener = nil
}

deinit {
  unsubscribe()
}
```

## Mapping with Codable
Use Firestore's built-in `Codable` support for clean model mapping.

```swift
struct TaskItem: Codable, Identifiable {
  @DocumentID var id: String?
  @ServerTimestamp var createdAt: Date?
  var title: String
}

// In Repository
let item = try snapshot.data(as: TaskItem.self)
```

## Safe Writes
Ensure that writes are performed from the `@MainActor` to avoid race conditions. Always prefer Firestore's native `async` methods.

```swift
@MainActor
func addTask(_ task: TaskItem) async throws {
  try await db.collection("tasks").addDocument(from: task)
}

@MainActor
func updateTask(_ task: TaskItem) async throws {
  if let documentID = task.id {
    try await db.collection("tasks").document(documentID).setData(from: task)
  }
}
```
