import SwiftUI

struct TaskListView: View {
  @State private var repository = TaskRepository()
  @State private var isPresentingAddTask = false
  @State private var errorMessage: String?
  @State private var isShowingError = false

  var body: some View {
    NavigationStack {
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
        .navigationTitle("Make It So")
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
    .sheet(isPresented: $isPresentingAddTask) {
      AddTaskView { task in
        Task {
          do {
            try await repository.addTask(task)
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
