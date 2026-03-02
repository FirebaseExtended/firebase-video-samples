import SwiftUI

struct AddTaskView: View {
  @Environment(\.dismiss) var dismiss
  var onAdd: (TaskItem) -> Void

  @State private var title = ""
  @State private var description = ""
  @State private var priority: TaskPriority = .medium
  @State private var dueDate = Date()

  var body: some View {
    NavigationStack {
      Form {
        Section {
          TextField("Task Title", text: $title)
          TextField("Description", text: $description, axis: .vertical)
            .lineLimit(3...10)
        }

        Section("Details") {
          Picker("Priority", selection: $priority) {
            ForEach(TaskPriority.allCases, id: \.self) { priority in
              Text(priority.rawValue).tag(priority)
            }
          }

          DatePicker("Due Date", selection: $dueDate)
        }
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
    let task = TaskItem(
      title: title, description: description.isEmpty ? nil : description, isCompleted: false,
      priority: priority, dueDate: dueDate)
    onAdd(task)
    dismiss()
  }
}
