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
      // Assuming we filter by userId. For anonymous auth, we might need to wait for auth state.
      // For MVP, we'll just listen to the collection and trust security rules or client-side filtering once auth is active.
      // Ideally, we'd wait for Auth to be ready.
      
      let query = db.collection("tasks")
        .order(by: "isCompleted")
        .order(by: "dueDate")
      
      // Note: Real filtering by userId requires the user to be logged in. 
      // We often need a "userId" field in the query if rules require it.
      
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
