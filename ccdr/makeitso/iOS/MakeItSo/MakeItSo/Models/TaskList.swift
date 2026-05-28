import FirebaseFirestore
import Foundation

struct TaskList: Codable, Identifiable, Hashable {
  @DocumentID var id: String? = nil
  var title: String
  var userId: String
  var sharedWith: [String]?
  var shareToken: String?
}
