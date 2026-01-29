import SwiftUI

struct TaskRowView: View {
  let task: TaskItem
  var onToggleCompleted: (TaskItem) -> Void

  var body: some View {
    HStack {
      Button {
        onToggleCompleted(task)
      } label: {
        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
          .resizable()
          .frame(width: 20, height: 20)
      }
      .buttonStyle(.plain)
      .accessibilityLabel(task.isCompleted ? "Mark as incomplete" : "Mark as complete")

      VStack(alignment: .leading) {
        Text(task.title)
          .strikethrough(task.isCompleted)
        if task.priority != .medium {
          Text(task.priority.rawValue)
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      }

      Spacer()
    }
  }
}
