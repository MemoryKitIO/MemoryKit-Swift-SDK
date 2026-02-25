import Foundation

/// Configuration for the MemoryKit client.
public struct Configuration: Sendable {

    /// The API key used for authentication. Must start with `ctx_`.
    public let apiKey: String

    /// The base URL for the MemoryKit API.
    public let baseURL: URL

    /// The request timeout interval in seconds.
    public let timeoutInterval: TimeInterval

    /// Maximum number of automatic retries for retryable errors (429, 5xx).
    public let maxRetries: Int

    /// The base delay in seconds for exponential backoff between retries.
    public let retryBaseDelay: TimeInterval

    /// Creates a new MemoryKit configuration.
    ///
    /// - Parameters:
    ///   - apiKey: Your MemoryKit API key (must start with `ctx_`).
    ///   - baseURL: The base URL for the API. Defaults to `https://api.memorykit.io/v1`.
    ///   - timeoutInterval: Request timeout in seconds. Defaults to `30`.
    ///   - maxRetries: Maximum retry attempts for retryable errors. Defaults to `3`.
    ///   - retryBaseDelay: Base delay for exponential backoff in seconds. Defaults to `1.0`.
    public init(
        apiKey: String,
        baseURL: URL = URL(string: "https://api.memorykit.io/v1")!,
        timeoutInterval: TimeInterval = 30,
        maxRetries: Int = 3,
        retryBaseDelay: TimeInterval = 1.0
    ) {
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.timeoutInterval = timeoutInterval
        self.maxRetries = maxRetries
        self.retryBaseDelay = retryBaseDelay
    }
}
