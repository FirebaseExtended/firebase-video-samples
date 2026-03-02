import FirebaseFirestore
import Foundation

struct TaskList: Codable, Identifiable {
  @DocumentID var id: String? = nil
  var title: String
  var userId: String
}
