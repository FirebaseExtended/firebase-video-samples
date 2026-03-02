import FirebaseFirestore
import Foundation

struct TaskList: Codable, Identifiable, Hashable {
  @DocumentID var id: String? = nil
  var title: String
  var userId: String

  static func == (lhs: TaskList, rhs: TaskList) -> Bool {
    lhs.id == rhs.id
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
