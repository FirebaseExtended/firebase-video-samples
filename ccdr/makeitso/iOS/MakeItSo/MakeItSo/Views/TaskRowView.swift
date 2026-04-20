import SwiftUI

struct TaskRowView: View {
  @Binding var task: TaskItem
  var onToggleCompleted: () -> Void

  var body: some View {
    HStack {
      Button {
        onToggleCompleted()
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

        if let description = task.description, !description.isEmpty {
          Text(description)
            .font(.caption)
            .foregroundStyle(.secondary)
            .lineLimit(2)
        }

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
