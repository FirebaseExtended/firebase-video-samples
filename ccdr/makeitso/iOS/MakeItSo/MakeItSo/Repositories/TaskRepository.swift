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

  init() {
    authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
      Task { @MainActor in
        guard let self = self else { return }
        self.user = user
        guard let user = user else {
          print("User is signed out")
          self.tasks = []
          self.unsubscribe()
          return
        }
        print("User is signed in: \(user.uid)")
        self.subscribe(userId: user.uid)
      }
    }
  }

  deinit {
    unsubscribe()
    if let handle = authStateListenerHandle {
      Auth.auth().removeStateDidChangeListener(handle)
    }
  }

  @MainActor func subscribe(userId: String) {
    if listenerRegistration == nil {
      print("Subscribing to tasks for user: \(userId)")
      let query = db.collection("tasks")
        .whereField("userId", isEqualTo: userId)
        .order(by: "isCompleted")
        .order(by: "dueDate")

      listenerRegistration =
        query
        .addSnapshotListener { [weak self] querySnapshot, error in
          guard let documents = querySnapshot?.documents else {
            print("No documents received or error: \(String(describing: error))")
            return
          }
          print("Received \(documents.count) tasks")

          let tasks = documents.compactMap { queryDocumentSnapshot -> TaskItem? in
            do {
              return try queryDocumentSnapshot.data(as: TaskItem.self)
            } catch {
              print("Error decoding task: \(error.localizedDescription)")
              return nil
            }
          }

          Task { @MainActor [weak self] in
            self?.tasks = tasks
          }
        }
    }
  }

  func unsubscribe() {
    listenerRegistration?.remove()
    listenerRegistration = nil
  }

  @MainActor func addTask(_ task: TaskItem) {
    do {
      var newTask = task
      // Assign current user ID if available
      if let userId = self.user?.uid {
        newTask.userId = userId
        print("Adding task with userId: \(userId)")
      } else {
        print("Warning: No logged in user, saving task without userId")
      }
      let _ = try db.collection("tasks").addDocument(from: newTask)
    } catch {
      print("Unable to add task: \(error.localizedDescription)")
    }
  }

  @MainActor func updateTask(_ task: TaskItem) {
    if let taskID = task.id {
      do {
        try db.collection("tasks").document(taskID).setData(from: task)
      } catch {
        print("Unable to update task: \(error.localizedDescription)")
      }
    }
  }

  @MainActor func deleteTask(_ task: TaskItem) {
    if let taskID = task.id {
      db.collection("tasks").document(taskID).delete { error in
        if let error = error {
          print("Unable to remove document: \(error.localizedDescription)")
        }
      }
    }
  }
}
