import FirebaseFirestore
import Foundation

struct TaskItem: Codable, Identifiable {
  @DocumentID var id: String? = nil
  var title: String
  var isCompleted: Bool
  var priority: TaskPriority
  var dueDate: Date? = nil
  @ServerTimestamp var createdAt: Date? = nil
  var userId: String? = nil
}

enum TaskPriority: String, Codable, CaseIterable, Hashable {
  case low = "Low"
  case medium = "Medium"
  case high = "High"
}
