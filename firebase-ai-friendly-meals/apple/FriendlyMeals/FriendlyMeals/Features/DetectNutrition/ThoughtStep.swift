import Foundation

struct ThoughtStep: Identifiable {
  var id = UUID()
  var headline: String
  var description: String

  init?(from thoughtSummary: String) {
    let parts = thoughtSummary.split(separator: "\n", maxSplits: 1, omittingEmptySubsequences: true)
    guard let headlinePart = parts.first else {
      return nil
    }
    
    self.headline = String(headlinePart).trimmingCharacters(in: .init(charactersIn: "*"))
    self.description = parts.count > 1 ? String(parts[1]).trimmingCharacters(in: .whitespacesAndNewlines) : ""
  }
  
  init (headline: String, description: String) {
    self.headline = headline
    self.description = description
  }
}
