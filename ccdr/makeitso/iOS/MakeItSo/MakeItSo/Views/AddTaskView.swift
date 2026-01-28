import SwiftUI

struct AddTaskView: View {
  @Environment(\.dismiss) var dismiss
  var onAdd: (Task) -> Void
  
  @State private var title = ""
  @State private var priority: TaskPriority = .medium
  @State private var dueDate = Date()
  
  var body: some View {
    NavigationStack {
      Form {
        TextField("Task Title", text: $title)
          .onSubmit {
            submit()
          }
        
        Picker("Priority", selection: $priority) {
          ForEach(TaskPriority.allCases, id: \.self) { priority in
            Text(priority.rawValue).tag(priority)
          }
        }
        
        DatePicker("Due Date", selection: $dueDate)
      }
      .navigationTitle("New Task")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") {
            dismiss()
          }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Add") {
            submit()
          }
          .disabled(title.isEmpty)
        }
      }
    }
  }
  
  private func submit() {
    let task = Task(title: title, isCompleted: false, priority: priority, dueDate: dueDate)
    onAdd(task)
    dismiss()
  }
}
