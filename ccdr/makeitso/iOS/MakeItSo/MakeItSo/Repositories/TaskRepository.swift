import FirebaseAuth
import FirebaseFirestore
import Foundation
import Observation
import os

@Observable
class TaskRepository {
  private let logger = Logger(subsystem: "com.google.firebase.example.MakeItSo", category: "Database")
  @MainActor var tasks = [TaskItem]()

  @MainActor var user: User? = nil

  private var db = Firestore.firestore()
  private var listenerRegistration: ListenerRegistration?
  private var authStateListenerHandle: AuthStateDidChangeListenerHandle?

  private var currentUserId: String?
  private var currentListId: String?

  init() {
    print("TaskRepository: Initializing")
    authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
      print("TaskRepository: Auth state changed, user: \(user?.uid ?? "nil")")
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

    let listInfo = listId.map { " in list: \($0)" } ?? ""
    logger.log("Subscribing to tasks for user: \(userId)\(listInfo)")

    var query: Query = db.collection("tasks")

    if let listId = listId {
      query = query.whereField("listId", isEqualTo: listId)
    } else {
      query = query.whereField("userId", isEqualTo: userId)
    }

    query = query
      .order(by: "isCompleted")
      .order(by: "dueDate")

    listenerRegistration = query.addSnapshotListener { [weak self] querySnapshot, error in
      guard let self = self else { return }
      if let error = error {
        self.logger.error("Error in snapshot listener: \(error.localizedDescription)")
        return
      }
      guard let documents = querySnapshot?.documents else {
        self.logger.log("No documents in snapshot")
        return
      }
      self.logger.log("Received snapshot with \(documents.count) tasks. Source: \(querySnapshot?.metadata.hasPendingWrites == true ? "Local" : "Server")")

      let tasks = documents.compactMap { document -> TaskItem? in
        do {
          let task = try document.data(as: TaskItem.self)
          return task
        } catch {
          self.logger.error("Error decoding task \(document.documentID): \(error.localizedDescription)")
          return nil
        }
      }

      Task { @MainActor in
        print("TaskRepository: Updating tasks array with \(tasks.count) items")
        self.tasks = tasks
      }
    }
  }

  func unsubscribe() {
    listenerRegistration?.remove()
    listenerRegistration = nil
  }

  @MainActor func addTask(_ task: TaskItem) async throws {
    logger.log("Adding task: \(task.title)")

    guard let uid = user?.uid else {
      logger.error("Cannot add task: No user logged in")
      return
    }

    var data: [String: Any] = [
      "title": task.title,
      "isCompleted": task.isCompleted,
      "priority": task.priority.rawValue,
      "userId": uid,
      "createdAt": FieldValue.serverTimestamp()
    ]

    if let description = task.description { data["description"] = description }
    if let dueDate = task.dueDate { data["dueDate"] = Timestamp(date: dueDate) }
    if let listId = task.listId { data["listId"] = listId }

    let docRef = try await db.collection("tasks").addDocument(data: data)
    logger.log("Task added with ID: \(docRef.documentID)")
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
