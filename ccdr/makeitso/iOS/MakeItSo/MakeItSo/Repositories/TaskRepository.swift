import FirebaseAuth
import FirebaseFirestore
import Foundation
import Observation

/// A repository responsible for managing tasks and their synchronization with Firestore.
///
/// **Thread Safety & Isolation Strategy**:
/// This class uses "surgical" `@MainActor` isolation instead of class-level isolation.
///
/// - **UI properties** (`tasks`, `user`) are isolated to `@MainActor` to ensure safe updates
///   that trigger SwiftUI view refreshes.
/// - **Lifecycle methods** (add, update, delete) are also isolated to `@MainActor` as they
///   operate on or or are called from the UI layer.
/// - **The class itself** remains non-isolated at the top level. This is intentional to allow
///   the `deinit` method to safely access and modify internal state (like `listenerRegistration`)
///   without being blocked by actor isolation requirements, which would otherwise cause
///   build errors since `deinit` is inherently non-isolated.
@Observable
class TaskRepository {
  @MainActor var tasks = [TaskItem]()

  @MainActor var user: User? = nil

  private var db = Firestore.firestore()
  private var listenerRegistration: ListenerRegistration?
  private var authStateListenerHandle: AuthStateDidChangeListenerHandle?

  private var currentUserId: String?
  private var currentListId: String?

  init() {
    authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
      Task { @MainActor in
        guard let self = self else { return }
        self.user = user
        if let user = user {
          print("User is signed in: \(user.uid)")
          // We don't subscribe here anymore, we let the view decide what to subscribe to
        } else {
          print("User is signed out")
          self.tasks = []
          self.unsubscribe()
        }
      }
    }
  }

  deinit {
    unsubscribe()
    if let handle = authStateListenerHandle {
      Auth.auth().removeStateDidChangeListener(handle)
    }
  }

  @MainActor func subscribe(userId: String, listId: String? = nil) {
    if userId == currentUserId && listId == currentListId && listenerRegistration != nil {
      return
    }

    unsubscribe()

    currentUserId = userId
    currentListId = listId

    print("Subscribing to tasks for user: \(userId)\(listId != nil ? " in list: \(listId!)" : "")")

    var query = db.collection("tasks")
      .whereField("userId", isEqualTo: userId)

    if let listId = listId {
      query = query.whereField("listId", isEqualTo: listId)
    }

    query =
      query
      .order(by: "isCompleted")
      .order(by: "dueDate")

    listenerRegistration = query.addSnapshotListener { [weak self] querySnapshot, error in
      guard let documents = querySnapshot?.documents else {
        print("No documents received or error: \(String(describing: error))")
        return
      }
      print("Received \(documents.count) tasks")

      let tasks = documents.compactMap { document -> TaskItem? in
        do {
          return try document.data(as: TaskItem.self)
        } catch {
          print("Error decoding task: \(error.localizedDescription)")
          return nil
        }
      }

      Task { @MainActor in
        self?.tasks = tasks
      }
    }
  }

  func unsubscribe() {
    listenerRegistration?.remove()
    listenerRegistration = nil
  }

  @MainActor func addTask(_ task: TaskItem) async throws {
    var newTask = task
    if let user = user {
      newTask.userId = user.uid
    } else {
      print("Warning: No logged in user, saving task without userId")
    }

    // listId is already on the taskItem if we're adding it from a specific list
    let _ = try await db.collection("tasks").addDocument(from: newTask)
  }

  @MainActor func updateTask(_ task: TaskItem) async throws {
    if let taskID = task.id {
      try await db.collection("tasks").document(taskID).setData(from: task)
    }
  }

  @MainActor func deleteTask(_ task: TaskItem) async throws {
    if let taskID = task.id {
      try await db.collection("tasks").document(taskID).delete()
    }
  }
}
