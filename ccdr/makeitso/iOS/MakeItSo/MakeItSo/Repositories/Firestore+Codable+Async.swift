import FirebaseFirestore
import Foundation

// TODO: Remove this file once native async/await support for Codable lands in the Firebase SDK.

extension CollectionReference {
  /// Bridging extension to provide async/await support for addDocument(from:).
  @discardableResult
  func addDocument<T: Encodable>(from value: T, encoder: Firestore.Encoder = Firestore.Encoder())
    async throws -> DocumentReference
  {
    try await withCheckedThrowingContinuation { continuation in
      do {
        var ref: DocumentReference?
        ref = try self.addDocument(from: value, encoder: encoder) { error in
          if let error = error {
            continuation.resume(throwing: error)
          } else if let ref = ref {
            continuation.resume(returning: ref)
          }
        }
      } catch {
        continuation.resume(throwing: error)
      }
    }
  }
}

extension DocumentReference {
  /// Bridging extension to provide async/await support for setData(from:).
  func setData<T: Encodable>(
    from value: T, merge: Bool = false, encoder: Firestore.Encoder = Firestore.Encoder()
  ) async throws {
    try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
      do {
        try self.setData(from: value, merge: merge, encoder: encoder) { error in
          if let error = error {
            continuation.resume(throwing: error)
          } else {
            continuation.resume()
          }
        }
      } catch {
        continuation.resume(throwing: error)
      }
    }
  }
}
