import Foundation

/// A user event in MemoryKit.
public struct UserEvent: Codable, Sendable, Identifiable {
    /// Unique identifier for the event.
    public let id: String?

    /// The type of event (e.g., "page_view", "click").
    public let type: String

    /// Event-specific data.
    public let data: [String: JSONValue]?

    /// The user ID associated with this event.
    public let userId: String?

    /// The date the event was created.
    public let createdAt: Date?
}

// MARK: - Request Bodies

/// Request body for creating a user event.
struct CreateEventRequest: Encodable {
    let type: String
    var data: [String: JSONValue]?
}
