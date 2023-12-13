import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

struct MyFavourite: Codable {
  var isPublic: Bool

  var number: Int
  var color: String
  var movie: String
  var food: String
  var city: String
  var userId: String
}

extension Introduction {
  func fetchDocumentCodableAsync() {
  }

  func createDocumentCodable() {
  }
}

