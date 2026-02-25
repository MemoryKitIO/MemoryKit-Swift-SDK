import Foundation

/// Response from the status endpoint.
public struct StatusResponse: Decodable, Sendable {
    /// The service status (e.g., "ok", "degraded").
    public let status: String

    /// The API version.
    public let version: String?

    /// The current timestamp.
    public let timestamp: Date?

    /// Additional service details.
    public let services: [String: JSONValue]?
}
