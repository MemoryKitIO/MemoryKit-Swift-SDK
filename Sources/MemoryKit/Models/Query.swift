import Foundation

// V2: QueryResponse disabled for initial launch.
// The RAG query endpoint will be re-enabled when LLM-powered features are available.

// public struct QueryResponse: Decodable, Sendable {
//     public let answer: String
//     public let confidence: Double?
//     public let sources: [Source]?
//     public let model: String?
//     public let requestId: String?
//     public let usage: Usage?
// }

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

// V2: QueryRequest disabled for initial launch.
// struct QueryRequest: Encodable {
//     let query: String
//     var maxSources: Int?
//     var temperature: Double?
//     var mode: String?
//     var userId: String?
//     var instructions: String?
//     var responseFormat: String?
//     var includeGraph: Bool?
//     var filters: QueryFilters?
//     var stream: Bool?
// }
