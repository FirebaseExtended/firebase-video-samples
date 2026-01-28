import FirebaseAuth
import FirebaseFirestore
import Foundation
import Observation

@Observable
class TaskRepository {
  var tasks = [Task]()

  private var db = Firestore.firestore()
  private var listenerRegistration: ListenerRegistration?
  private var authStateListenerHandle: AuthStateDidChangeListenerHandle?

  init() {
    authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
      guard let self = self else { return }
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

  deinit {
    unsubscribe()
    if let handle = authStateListenerHandle {
      Auth.auth().removeStateDidChangeListener(handle)
    }
  }

  func subscribe(userId: String) {
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

          self?.tasks = documents.compactMap { queryDocumentSnapshot in
            do {
              return try queryDocumentSnapshot.data(as: Task.self)
            } catch {
              print("Error decoding task: \(error.localizedDescription)")
              return nil
            }
          }
        }
    }
  }

  func unsubscribe() {
    listenerRegistration?.remove()
    listenerRegistration = nil
  }

  func addTask(_ task: Task) {
    do {
      var newTask = task
      // Assign current user ID if available
      if let userId = Auth.auth().currentUser?.uid {
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

  func updateTask(_ task: Task) {
    if let taskID = task.id {
      do {
        try db.collection("tasks").document(taskID).setData(from: task)
      } catch {
        print("Unable to update task: \(error.localizedDescription)")
      }
    }
  }

  func deleteTask(_ task: Task) {
    if let taskID = task.id {
      db.collection("tasks").document(taskID).delete { error in
        if let error = error {
          print("Unable to remove document: \(error.localizedDescription)")
        }
      }
    }
  }
}
