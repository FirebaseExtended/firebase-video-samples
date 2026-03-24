import Foundation
import FirebaseAuth

class ListJoinService {
  static let shared = ListJoinService()
  
  func joinList(listId: String, shareToken: String) async throws {
    guard let user = Auth.auth().currentUser else {
      throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
    }
    
    let idToken = try await user.getIDToken()
    let url = URL(string: "https://us-central1-make-it-so-live-ccdr-01.cloudfunctions.net/joinList")!
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
    
    let body: [String: Any] = [
      "data": [
        "listId": listId,
        "shareToken": shareToken
      ]
    ]
    
    request.httpBody = try JSONSerialization.data(withJSONObject: body)
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
      let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown Error"
      throw NSError(domain: "CloudFunctions", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg])
    }
  }
}
