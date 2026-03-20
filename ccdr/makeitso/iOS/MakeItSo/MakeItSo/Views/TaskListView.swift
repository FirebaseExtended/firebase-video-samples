import FirebaseAuth
import SwiftUI

struct TaskListView: View {
  var taskList: TaskList? = nil
  @State private var repository = TaskRepository()
  @State private var isPresentingAddTask = false
  @State private var errorMessage: String?
  @State private var isShowingError = false

  var body: some View {
    Group {
      if repository.user == nil {
        ProgressView("Signing in...")
      } else {
        List {
          ForEach(repository.tasks) { task in
            TaskRowView(task: task) { taskToToggle in
              toggleTask(taskToToggle)
            }
          }
          .onDelete { indexSet in
            delete(at: indexSet)
          }
        }
        .navigationTitle(taskList?.title ?? "Tasks")
        .toolbar {
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
    .task(id: repository.user) {
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
  }

  private func showError(_ error: Error) {
    errorMessage = error.localizedDescription
    isShowingError = true
  }

  private func toggleTask(_ task: TaskItem) {
    var updatedTask = task
    updatedTask.isCompleted.toggle()
    Task {
      do {
        try await repository.updateTask(updatedTask)
      } catch {
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
