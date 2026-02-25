import Foundation

/// A webhook registration in MemoryKit.
public struct Webhook: Codable, Sendable, Identifiable {
    /// Unique identifier for the webhook.
    public let id: String

    /// The URL that receives webhook events.
    public let url: String

    /// The event types this webhook is subscribed to.
    public let events: [String]?

    /// The webhook secret for verifying payloads.
    public let secret: String?

    /// Whether the webhook is active.
    public let active: Bool?

    /// The date the webhook was created.
    public let createdAt: Date?

    /// The date the webhook was last updated.
    public let updatedAt: Date?
}

/// Response from testing a webhook.
public struct WebhookTestResponse: Decodable, Sendable {
    /// Whether the test was successful.
    public let success: Bool?

    /// The HTTP status code returned by the webhook endpoint.
    public let statusCode: Int?

    /// The response body from the webhook endpoint.
    public let responseBody: String?

    /// An error message if the test failed.
    public let error: String?
}

// MARK: - Request Bodies

/// Request body for registering a webhook.
struct CreateWebhookRequest: Encodable {
    let url: String
    var events: [String]?
}
