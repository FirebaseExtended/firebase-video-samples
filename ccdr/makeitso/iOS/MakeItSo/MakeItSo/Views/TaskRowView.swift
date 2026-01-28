import SwiftUI

struct TaskRowView: View {
  let task: TaskItem
  var onToggleCompleted: (TaskItem) -> Void

  var body: some View {
    HStack {
      Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
        .resizable()
        .frame(width: 20, height: 20)
        .onTapGesture {
          onToggleCompleted(task)
        }

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
