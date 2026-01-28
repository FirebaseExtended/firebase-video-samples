import Foundation
import FirebaseFirestore
import Observation
import FirebaseAuth

@Observable
class TaskRepository {
  var tasks = [Task]()
  
  private var db = Firestore.firestore()
  private var listenerRegistration: ListenerRegistration?
  
  init() {
    subscribe()
  }
  
  deinit {
    unsubscribe()
  }
  
  func subscribe() {
    if listenerRegistration == nil {
      guard let userId = Auth.auth().currentUser?.uid else {
        return
      }
      
      let query = db.collection("tasks")
        .whereField("userId", isEqualTo: userId)
        .order(by: "isCompleted")
        .order(by: "dueDate")
      
      listenerRegistration = query
        .addSnapshotListener { [weak self] querySnapshot, error in
          guard let documents = querySnapshot?.documents else {
            print("No documents")
            return
          }
          
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
      }
      let _ = try db.collection("tasks").addDocument(from: newTask)
    }
    catch {
      print("Unable to add task: \(error.localizedDescription)")
    }
  }
  
  func updateTask(_ task: Task) {
    if let taskID = task.id {
      do {
        try db.collection("tasks").document(taskID).setData(from: task)
      }
      catch {
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
