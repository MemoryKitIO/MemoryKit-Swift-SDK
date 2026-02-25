import Foundation

/// The main MemoryKit client for interacting with the MemoryKit API.
///
/// Use the resource properties (`memories`, `chats`, `users`, `webhooks`, `status`, `feedback`)
/// to access specific API endpoints.
///
/// ```swift
/// let mk = MemoryKit(apiKey: "ctx_...")
///
/// // Create a memory
/// let memory = try await mk.memories.create(
///     content: "Meeting notes from Q4...",
///     title: "Q4 Planning Notes",
///     tags: ["planning", "q4"]
/// )
///
/// // Query memories
/// let answer = try await mk.memories.query(
///     query: "Summarize our Q4 goals",
///     mode: "balanced"
/// )
/// ```
public final class MemoryKit: Sendable {

    /// The SDK version.
    public static let version = "0.1.1"

    /// The configuration used by this client.
    public let configuration: Configuration

    private let client: HTTPClient

    /// Resource for interacting with memories.
    public let memories: MemoriesResource

    /// Resource for interacting with chats.
    public let chats: ChatsResource

    /// Resource for interacting with users and user events.
    public let users: UsersResource

    /// Resource for interacting with webhooks.
    public let webhooks: WebhooksResource

    /// Resource for checking API status.
    public let status: StatusResource

    /// Resource for submitting feedback.
    public let feedback: FeedbackResource

    /// Creates a new MemoryKit client.
    ///
    /// - Parameters:
    ///   - apiKey: Your MemoryKit API key (must start with `ctx_`).
    ///   - baseURL: The base URL for the API. Defaults to `https://api.memorykit.io/v1`.
    ///   - timeout: Request timeout in seconds. Defaults to `30`.
    ///   - maxRetries: Maximum retry attempts for retryable errors. Defaults to `3`.
    public convenience init(
        apiKey: String,
        baseURL: URL = URL(string: "https://api.memorykit.io/v1")!,
        timeout: TimeInterval = 30,
        maxRetries: Int = 3
    ) {
        let configuration = Configuration(
            apiKey: apiKey,
            baseURL: baseURL,
            timeoutInterval: timeout,
            maxRetries: maxRetries
        )
        self.init(configuration: configuration)
    }

    /// Creates a new MemoryKit client with a full configuration.
    ///
    /// - Parameter configuration: The client configuration.
    public init(configuration: Configuration) {
        self.configuration = configuration
        self.client = HTTPClient(configuration: configuration)
        self.memories = MemoriesResource(client: client)
        self.chats = ChatsResource(client: client)
        self.users = UsersResource(client: client)
        self.webhooks = WebhooksResource(client: client)
        self.status = StatusResource(client: client)
        self.feedback = FeedbackResource(client: client)
    }
}
