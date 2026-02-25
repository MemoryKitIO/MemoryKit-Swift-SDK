import Foundation

/// Response from a RAG query.
public struct QueryResponse: Decodable, Sendable {
    /// The generated answer.
    public let answer: String

    /// The confidence score of the answer (0.0 - 1.0).
    public let confidence: Double?

    /// Source memories referenced in the answer.
    public let sources: [Source]?

    /// The model used to generate the answer.
    public let model: String?

    /// A unique request ID for this query.
    public let requestId: String?

    /// Token usage information.
    public let usage: Usage?
}

/// A source memory referenced in a query or search result.
public struct Source: Codable, Sendable {
    /// The memory ID.
    public let id: String?

    /// The title of the source memory.
    public let title: String?

    /// A snippet of the source content.
    public let content: String?

    /// The relevance score.
    public let score: Double?

    /// Metadata from the source memory.
    public let metadata: [String: JSONValue]?
}

/// Filters that can be applied to queries and searches.
public struct QueryFilters: Encodable, Sendable {
    /// Filter by memory type.
    public var type: String?

    /// Filter by tags (memories must have all specified tags).
    public var tags: [String]?

    /// Filter by user ID.
    public var userId: String?

    /// Filter by metadata key-value pairs.
    public var metadata: [String: JSONValue]?

    public init(
        type: String? = nil,
        tags: [String]? = nil,
        userId: String? = nil,
        metadata: [String: JSONValue]? = nil
    ) {
        self.type = type
        self.tags = tags
        self.userId = userId
        self.metadata = metadata
    }
}

// MARK: - Request Bodies

/// Request body for a RAG query.
struct QueryRequest: Encodable {
    let query: String
    var maxSources: Int?
    var temperature: Double?
    var mode: String?
    var userId: String?
    var instructions: String?
    var responseFormat: String?
    var includeGraph: Bool?
    var filters: QueryFilters?
    var stream: Bool?
}
