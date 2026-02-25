import Foundation

/// Resource for interacting with the Chats API.
public struct ChatsResource: Sendable {

    private let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    // MARK: - CRUD

    /// Creates a new chat conversation.
    ///
    /// - Parameters:
    ///   - userId: The user ID to associate with the chat.
    ///   - title: An optional title for the chat.
    ///   - metadata: Arbitrary key-value metadata.
    /// - Returns: The created chat.
    @discardableResult
    public func create(
        userId: String? = nil,
        title: String? = nil,
        metadata: [String: JSONValue]? = nil
    ) async throws -> Chat {
        let body = CreateChatRequest(
            userId: userId,
            title: title,
            metadata: metadata
        )
        return try await client.post(path: "/chats", body: body)
    }

    /// Lists chats with cursor-based pagination.
    ///
    /// - Parameters:
    ///   - userId: Filter by user ID.
    ///   - limit: Maximum number of results per page. Defaults to 20.
    ///   - cursor: A cursor for pagination from a previous response.
    /// - Returns: A paginated list of chats.
    public func list(
        userId: String? = nil,
        limit: Int? = nil,
        cursor: String? = nil
    ) async throws -> ListResponse<Chat> {
        var queryItems = [URLQueryItem]()
        if let userId = userId { queryItems.append(URLQueryItem(name: "userId", value: userId)) }
        if let limit = limit { queryItems.append(URLQueryItem(name: "limit", value: String(limit))) }
        if let cursor = cursor { queryItems.append(URLQueryItem(name: "cursor", value: cursor)) }

        return try await client.get(path: "/chats", queryItems: queryItems.isEmpty ? nil : queryItems)
    }

    /// Retrieves a chat with its message history.
    ///
    /// - Parameter id: The chat ID.
    /// - Returns: The chat with all its messages.
    public func getHistory(_ id: String) async throws -> ChatWithMessages {
        return try await client.get(path: "/chats/\(id)")
    }

    /// Sends a message in a chat and gets the assistant's response.
    ///
    /// - Parameters:
    ///   - id: The chat ID.
    ///   - message: The message content (required).
    ///   - mode: Query mode (e.g., "balanced", "precise", "creative").
    /// - Returns: The assistant's response message.
    public func sendMessage(
        _ id: String,
        message: String,
        mode: String? = nil
    ) async throws -> ChatMessageResponse {
        let body = SendMessageRequest(message: message, mode: mode)
        return try await client.post(path: "/chats/\(id)/messages", body: body)
    }

    /// Streams a message response as server-sent events.
    ///
    /// - Parameters:
    ///   - id: The chat ID.
    ///   - message: The message content (required).
    ///   - mode: Query mode (e.g., "balanced", "precise", "creative").
    /// - Returns: An `AsyncSequence` of SSE events.
    public func streamMessage(
        _ id: String,
        message: String,
        mode: String? = nil
    ) async throws -> SSEStream {
        let body = SendMessageRequest(message: message, mode: mode)
        let (bytes, _) = try await client.postStream(path: "/chats/\(id)/messages/stream", body: body)
        return SSEStream(bytes: bytes)
    }

    /// Deletes a chat and all its messages.
    ///
    /// - Parameter id: The chat ID.
    public func delete(_ id: String) async throws {
        try await client.delete(path: "/chats/\(id)")
    }
}
