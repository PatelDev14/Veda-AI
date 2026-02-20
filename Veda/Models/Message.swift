import Foundation

enum MessageRole {
    case user
    case assistant
}

struct Message: Identifiable, Equatable {
    let id = UUID()
    let role: MessageRole
    var content: String
    let timestamp: Date = Date()
    
    var isUser: Bool { role == .user }
}
