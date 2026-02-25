import Foundation

/// A user in MemoryKit.
public struct User: Codable, Sendable, Identifiable {
    /// Unique identifier for the user.
    public let id: String

    /// The user's email address.
    public let email: String?

    /// The user's name.
    public let name: String?

    /// Arbitrary metadata associated with the user.
    public let metadata: [String: JSONValue]?

    /// The date the user was created.
    public let createdAt: Date?

    /// The date the user was last updated.
    public let updatedAt: Date?
}

// MARK: - Request Bodies

/// Request body for upserting (creating or updating) a user.
struct UpsertUserRequest: Encodable {
    let id: String
    var email: String?
    var name: String?
    var metadata: [String: JSONValue]?
}

/// Request body for updating a user.
struct UpdateUserRequest: Encodable {
    var email: String?
    var name: String?
    var metadata: [String: JSONValue]?
}
