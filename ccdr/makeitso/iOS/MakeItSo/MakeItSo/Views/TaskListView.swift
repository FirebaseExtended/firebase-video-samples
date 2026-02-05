import SwiftUI

struct TaskListView: View {
  @State private var repository = TaskRepository()
  @State private var isPresentingAddTask = false
  
  var body: some View {
    NavigationStack {
      List {
        ForEach(repository.tasks) { task in
          TaskRowView(task: task) { task in
            var updatedTask = task
            updatedTask.isCompleted.toggle()
            repository.updateTask(updatedTask)
          }
        }
        .onDelete { indexSet in
          indexSet.forEach { index in
            let task = repository.tasks[index]
            repository.deleteTask(task)
          }
        }
      }
      .navigationTitle("Tasks")
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          Button {
            isPresentingAddTask = true
          } label: {
            Image(systemName: "plus")
          }
        }
      }
      .sheet(isPresented: $isPresentingAddTask) {
        AddTaskView { task in
          repository.addTask(task)
        }
      }
    }
  }
}
