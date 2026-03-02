import FirebaseAuth
import FirebaseFirestore
import Foundation
import Observation

@Observable
class TaskListRepository {
  @MainActor var groups = [TaskList]()
  @MainActor var user: User? = nil

  private var db = Firestore.firestore()
  private var listenerRegistration: ListenerRegistration?
  private var authStateListenerHandle: AuthStateDidChangeListenerHandle?

  init() {
    authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
      Task { @MainActor in
        guard let self = self else { return }
        self.user = user
        if let user = user {
          self.subscribe(userId: user.uid)
        } else {
          self.groups = []
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

  @MainActor func subscribe(userId: String) {
    if listenerRegistration == nil {
      let query = db.collection("lists")
        .whereField("userId", isEqualTo: userId)
        .order(by: "title")

      listenerRegistration = query.addSnapshotListener { [weak self] querySnapshot, error in
        guard let documents = querySnapshot?.documents else { return }
        let groups = documents.compactMap { try? $0.data(as: TaskList.self) }

        Task { @MainActor in
          self?.groups = groups
        }
      }
    }
  }

  func unsubscribe() {
    listenerRegistration?.remove()
    listenerRegistration = nil
  }

  @MainActor func addList(_ list: TaskList) async throws {
    var newList = list
    if let user = user {
      newList.userId = user.uid
    }
    let _ = try await db.collection("lists").addDocument(from: newList)
  }

  @MainActor func updateList(_ list: TaskList) async throws {
    if let listID = list.id {
      try await db.collection("lists").document(listID).setData(from: list)
    }
  }

  @MainActor func deleteList(_ list: TaskList) async throws {
    if let listID = list.id {
      try await db.collection("lists").document(listID).delete()
    }
  }
}
