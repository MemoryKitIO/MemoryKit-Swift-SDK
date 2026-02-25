import Foundation

/// Resource for checking MemoryKit API status.
public struct StatusResource: Sendable {

    private let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    /// Checks the current API status.
    ///
    /// - Returns: The status response.
    public func check() async throws -> StatusResponse {
        return try await client.get(path: "/status")
    }
}
