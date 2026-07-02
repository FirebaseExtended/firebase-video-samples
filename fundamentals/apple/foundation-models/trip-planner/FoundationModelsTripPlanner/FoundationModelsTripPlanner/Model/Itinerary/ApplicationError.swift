import Foundation

public struct ApplicationError: Error, Sendable, CustomNSError {
  let localizedDescription: String
  let message: String

  init(_ localizedDescription: String) {
    self.localizedDescription = localizedDescription
    self.message = localizedDescription
  }

  public var errorUserInfo: [String: Any] {
    [
      NSLocalizedDescriptionKey: localizedDescription,
    ]
  }
}
