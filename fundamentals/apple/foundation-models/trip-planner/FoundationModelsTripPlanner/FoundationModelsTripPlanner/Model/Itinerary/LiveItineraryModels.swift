import Foundation

struct TranscriptMessage: Identifiable, Equatable {
    let id = UUID()
    var text: String
    let isUser: Bool
}

enum SpeakerState: Equatable {
    case idle
    case ai
    case user
}

enum ConnectionState: Equatable {
    case disconnected
    case disconnecting
    case connecting
    case connected
    case error(String)
}
