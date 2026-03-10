import Foundation

// V2: Chat types disabled for initial launch.
// The chats API will be re-enabled when LLM-powered chat endpoints are available.

// public struct Chat: Codable, Sendable, Identifiable {
//     public let id: String
//     public let userId: String?
//     public let title: String?
//     public let metadata: [String: JSONValue]?
//     public let createdAt: Date?
//     public let updatedAt: Date?
// }
//
// public struct ChatMessage: Codable, Sendable, Identifiable {
//     public let id: String?
//     public let role: String
//     public let content: String
//     public let createdAt: Date?
// }
//
// public struct ChatWithMessages: Decodable, Sendable {
//     public let id: String
//     public let userId: String?
//     public let title: String?
//     public let metadata: [String: JSONValue]?
//     public let createdAt: Date?
//     public let updatedAt: Date?
//     public let messages: [ChatMessage]
// }
//
// public struct ChatMessageResponse: Decodable, Sendable {
//     public let message: ChatMessage
//     public let sources: [Source]?
//     public let usage: Usage?
// }
//
// // MARK: - Request Bodies
//
// struct CreateChatRequest: Encodable {
//     var userId: String?
//     var title: String?
//     var metadata: [String: JSONValue]?
// }
//
// struct SendMessageRequest: Encodable {
//     let message: String
//     var mode: String?
// }
