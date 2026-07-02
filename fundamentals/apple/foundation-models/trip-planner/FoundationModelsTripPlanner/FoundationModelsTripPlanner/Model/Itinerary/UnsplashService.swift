/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A service to fetch images from Unsplash.
*/

import Foundation

struct UnsplashResponse: Codable {
    let results: [UnsplashPhoto]
}

struct UnsplashPhoto: Codable {
    let urls: UnsplashUrls
}

struct UnsplashUrls: Codable {
    let regular: String
}

struct UnsplashService {
    private var accessKey: String {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let key = dict["UnsplashAccessKey"] as? String else {
            return "YOUR_UNSPLASH_ACCESS_KEY"
        }
        return key
    }
    
    func searchPhotos(query: String) async throws -> String? {
        var components = URLComponents(string: "https://api.unsplash.com/search/photos")!
        components.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "per_page", value: "1")
        ]
        
        guard let url = components.url else { return nil }
        
        var request = URLRequest(url: url)
        request.setValue("Client-ID \(accessKey)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(UnsplashResponse.self, from: data)
        
        return response.results.first?.urls.regular
    }
}
