import Foundation

/// Resource for interacting with the Users API, including user events.
public struct UsersResource: Sendable {

    private let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    // MARK: - Users

    /// Creates or updates a user (upsert).
    ///
    /// - Parameters:
    ///   - id: The unique user ID (required).
    ///   - email: The user's email address.
    ///   - name: The user's name.
    ///   - metadata: Arbitrary key-value metadata.
    /// - Returns: The created or updated user.
    @discardableResult
    public func upsert(
        id: String,
        email: String? = nil,
        name: String? = nil,
        metadata: [String: JSONValue]? = nil
    ) async throws -> User {
        let body = UpsertUserRequest(
            id: id,
            email: email,
            name: name,
            metadata: metadata
        )
        return try await client.post(path: "/users", body: body)
    }

    /// Retrieves a user by ID.
    ///
    /// - Parameter id: The user ID.
    /// - Returns: The user.
    public func get(_ id: String) async throws -> User {
        return try await client.get(path: "/users/\(id)")
    }

    /// Updates an existing user.
    ///
    /// - Parameters:
    ///   - id: The user ID.
    ///   - email: Updated email.
    ///   - name: Updated name.
    ///   - metadata: Updated metadata.
    /// - Returns: The updated user.
    @discardableResult
    public func update(
        _ id: String,
        email: String? = nil,
        name: String? = nil,
        metadata: [String: JSONValue]? = nil
    ) async throws -> User {
        let body = UpdateUserRequest(
            email: email,
            name: name,
            metadata: metadata
        )
        return try await client.put(path: "/users/\(id)", body: body)
    }

    /// Deletes a user by ID.
    ///
    /// - Parameters:
    ///   - id: The user ID.
    ///   - cascade: If true, also deletes all memories and chats associated with the user.
    public func delete(_ id: String, cascade: Bool? = nil) async throws {
        var queryItems: [URLQueryItem]?
        if let cascade = cascade {
            queryItems = [URLQueryItem(name: "cascade", value: String(cascade))]
        }
        try await client.delete(path: "/users/\(id)", queryItems: queryItems)
    }

    // MARK: - User Events

    /// Creates an event for a user.
    ///
    /// - Parameters:
    ///   - userId: The user ID.
    ///   - type: The event type (e.g., "page_view", "click").
    ///   - data: Event-specific data.
    /// - Returns: The created event.
    @discardableResult
    public func createEvent(
        _ userId: String,
        type: String,
        data: [String: JSONValue]? = nil
    ) async throws -> UserEvent {
        let body = CreateEventRequest(type: type, data: data)
        return try await client.post(path: "/users/\(userId)/events", body: body)
    }

    /// Lists events for a user.
    ///
    /// - Parameters:
    ///   - userId: The user ID.
    ///   - limit: Maximum number of results. Defaults to 20.
    ///   - type: Filter by event type.
    /// - Returns: A list of events.
    public func listEvents(
        _ userId: String,
        limit: Int? = nil,
        type: String? = nil
    ) async throws -> ListResponse<UserEvent> {
        var queryItems = [URLQueryItem]()
        if let limit = limit { queryItems.append(URLQueryItem(name: "limit", value: String(limit))) }
        if let type = type { queryItems.append(URLQueryItem(name: "type", value: type)) }

        return try await client.get(
            path: "/users/\(userId)/events",
            queryItems: queryItems.isEmpty ? nil : queryItems
        )
    }

    /// Deletes a specific event for a user.
    ///
    /// - Parameters:
    ///   - userId: The user ID.
    ///   - eventId: The event ID.
    public func deleteEvent(_ userId: String, eventId: String) async throws {
        try await client.delete(path: "/users/\(userId)/events/\(eventId)")
    }
}
