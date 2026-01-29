import SwiftUI

struct TaskListView: View {
  @State private var repository = TaskRepository()
  @State private var isPresentingAddTask = false

  var body: some View {
    NavigationStack {
      if repository.user == nil {
        ProgressView("Signing in...")
      } else {
        List {
          ForEach(repository.tasks) { task in
            TaskRowView(task: task) { task in
              toggleTask(task)
            }
          }
          .onDelete { indexSet in
            delete(at: indexSet)
          }
        }
        .navigationTitle("Tasks")
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
        repository.addTask(task)
      }
    }
  }

  private func toggleTask(_ task: TaskItem) {
    var updatedTask = task
    updatedTask.isCompleted.toggle()
    repository.updateTask(updatedTask)
  }

  private func delete(at indexSet: IndexSet) {
    indexSet.forEach { index in
      let task = repository.tasks[index]
      repository.deleteTask(task)
    }
  }
}
