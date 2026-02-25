import Foundation

/// Resource for interacting with the Webhooks API.
public struct WebhooksResource: Sendable {

    private let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    /// Registers a new webhook.
    ///
    /// - Parameters:
    ///   - url: The URL to receive webhook events (required).
    ///   - events: The event types to subscribe to.
    /// - Returns: The created webhook.
    @discardableResult
    public func create(
        url: String,
        events: [String]? = nil
    ) async throws -> Webhook {
        let body = CreateWebhookRequest(url: url, events: events)
        return try await client.post(path: "/webhooks", body: body)
    }

    /// Lists all registered webhooks.
    ///
    /// - Returns: A list of webhooks.
    public func list() async throws -> [Webhook] {
        return try await client.get(path: "/webhooks")
    }

    /// Retrieves a webhook by ID.
    ///
    /// - Parameter id: The webhook ID.
    /// - Returns: The webhook.
    public func get(_ id: String) async throws -> Webhook {
        return try await client.get(path: "/webhooks/\(id)")
    }

    /// Deletes a webhook by ID.
    ///
    /// - Parameter id: The webhook ID.
    public func delete(_ id: String) async throws {
        try await client.delete(path: "/webhooks/\(id)")
    }

    /// Sends a test event to a webhook.
    ///
    /// - Parameter id: The webhook ID.
    /// - Returns: The test result.
    public func test(_ id: String) async throws -> WebhookTestResponse {
        return try await client.post(path: "/webhooks/\(id)/test", body: EmptyBody())
    }
}
