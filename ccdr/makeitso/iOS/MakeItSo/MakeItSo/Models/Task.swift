import Foundation
import FirebaseFirestore

struct Task: Codable, Identifiable {
  @DocumentID var id: String?
  var title: String
  var isCompleted: Bool
  var priority: TaskPriority
  var dueDate: Date? // Optional, as tasks might not have a deadline
  @ServerTimestamp var createdAt: Date?
  var userId: String?
}

enum TaskPriority: String, Codable, CaseIterable {
  case low = "Low"
  case medium = "Medium"
  case high = "High"
}
