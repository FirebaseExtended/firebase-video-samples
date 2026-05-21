import FirebaseAuth
import SwiftUI
import OSLog

private let logger = Logger(subsystem: "com.google.firebase.example.MakeItSo", category: "Sharing")

struct TaskListView: View {
  private struct SubscriptionKey: Equatable {
    let userId: String?
    let listId: String?
  }

  var taskList: TaskList? = nil
  @State private var repository = TaskRepository()
  @State private var isPresentingAddTask = false
  @State private var errorMessage: String?
  @State private var isShowingError = false

  var body: some View {
    @Bindable var repository = repository
    Group {
      if repository.user == nil {
        ProgressView("Signing in...")
      } else {
        List {
          ForEach($repository.tasks) { $task in
            TaskRowView(task: $task) {
              toggleTask($task)
            }
          }
          .onDelete { indexSet in
            delete(at: indexSet)
          }
        }
        .navigationTitle(taskList?.title ?? "Tasks")
        .toolbar {
          if let list = taskList, let listId = list.id, let token = list.shareToken, let url = URL(string: "https://make-it-so-live-ccdr-01.web.app/join/\(listId)?token=\(token)") {
            ToolbarItem(placement: .primaryAction) {
              ShareLink(item: url, message: Text("Join my list: \(list.title)"))
                .simultaneousGesture(TapGesture().onEnded {
                  logger.log("SHARE_LINK_URL: \(url.absoluteString, privacy: .public)")
                })
            }
          }
          ToolbarItem(placement: .primaryAction) {
            Button {
              isPresentingAddTask = true
            } label: {
              Label("Add Task", systemImage: "plus")
            }
          }
        }
      }
    }
    .task(id: SubscriptionKey(userId: repository.user?.uid, listId: taskList?.id)) {
      if let user = repository.user {
        print("TaskListView: Subscribing for user \(user.uid) and list \(taskList?.id ?? "nil")")
        repository.subscribe(userId: user.uid, listId: taskList?.id)
      } else {
        print("TaskListView: No user yet")
      }
    }
    .sheet(isPresented: $isPresentingAddTask) {
      AddTaskView { task in
        var newTask = task
        newTask.listId = taskList?.id
        Task {
          do {
            try await repository.addTask(newTask)
          } catch {
            showError(error)
          }
        }
      }
    }
    .alert("Error", isPresented: $isShowingError, presenting: errorMessage) { _ in
      Button("OK", role: .cancel) {}
    } message: { message in
      Text(message)
    }
    .onAppear {
      if let list = taskList, let listId = list.id, let token = list.shareToken {
        let url = "https://make-it-so-live-ccdr-01.web.app/join/\(listId)?token=\(token)"
        logger.log("SHARE_LINK_URL: \(url, privacy: .public)")
      }
    }
  }

  private func showError(_ error: Error) {
    errorMessage = error.localizedDescription
    isShowingError = true
  }

  private func toggleTask(_ task: Binding<TaskItem>) {
    task.wrappedValue.isCompleted.toggle()
    let updatedTask = task.wrappedValue
    Task {
      do {
        try await repository.updateTask(updatedTask)
      } catch {
        task.wrappedValue.isCompleted.toggle()
        showError(error)
      }
    }
  }

  private func delete(at indexSet: IndexSet) {
    indexSet.forEach { index in
      let task = repository.tasks[index]
      Task {
        do {
          try await repository.deleteTask(task)
        } catch {
          showError(error)
        }
      }
    }
  }
}
