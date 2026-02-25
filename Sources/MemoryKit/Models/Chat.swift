import Foundation

/// A chat conversation in MemoryKit.
public struct Chat: Codable, Sendable, Identifiable {
    /// Unique identifier for the chat.
    public let id: String

    /// The user ID associated with this chat.
    public let userId: String?

    /// The title of the chat.
    public let title: String?

    /// Arbitrary metadata associated with the chat.
    public let metadata: [String: JSONValue]?

    /// The date the chat was created.
    public let createdAt: Date?

    /// The date the chat was last updated.
    public let updatedAt: Date?
}

/// A message within a chat.
public struct ChatMessage: Codable, Sendable, Identifiable {
    /// Unique identifier for the message.
    public let id: String?

    /// The role of the message sender (e.g., "user", "assistant").
    public let role: String

    /// The content of the message.
    public let content: String

    /// The date the message was created.
    public let createdAt: Date?
}

/// A chat with its message history.
public struct ChatWithMessages: Decodable, Sendable {
    /// The chat information.
    public let id: String
    public let userId: String?
    public let title: String?
    public let metadata: [String: JSONValue]?
    public let createdAt: Date?
    public let updatedAt: Date?

    /// The messages in the chat.
    public let messages: [ChatMessage]
}

/// Response from sending a message in a chat.
public struct ChatMessageResponse: Decodable, Sendable {
    /// The assistant's response message.
    public let message: ChatMessage

    /// Sources referenced in the response.
    public let sources: [Source]?

    /// Usage information.
    public let usage: Usage?
}

// MARK: - Request Bodies

/// Request body for creating a chat.
struct CreateChatRequest: Encodable {
    var userId: String?
    var title: String?
    var metadata: [String: JSONValue]?
}

/// Request body for sending a message in a chat.
struct SendMessageRequest: Encodable {
    let message: String
    var mode: String?
}
