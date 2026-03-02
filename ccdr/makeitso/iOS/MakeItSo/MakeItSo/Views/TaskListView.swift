import SwiftUI

struct TaskListView: View {
  var taskList: TaskList? = nil
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
    .onAppear {
      if let user = repository.user {
        repository.subscribe(userId: user.uid, listId: taskList?.id)
      }
    }
    .onChange(of: repository.user) { oldUser, newUser in
      if let user = newUser {
        repository.subscribe(userId: user.uid, listId: taskList?.id)
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
