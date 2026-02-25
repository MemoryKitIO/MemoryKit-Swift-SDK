import Foundation

/// Response from a hybrid search.
public struct SearchResponse: Decodable, Sendable {
    /// The search results.
    public let results: [SearchResult]

    /// Knowledge graph data, if requested.
    public let graph: GraphData?

    /// A unique request ID for this search.
    public let requestId: String?

    /// Total number of results matched.
    public let totalResults: Int?
}

/// A single search result.
public struct SearchResult: Decodable, Sendable {
    /// The memory ID.
    public let id: String?

    /// The title of the memory.
    public let title: String?

    /// The content of the memory.
    public let content: String?

    /// The relevance score.
    public let score: Double?

    /// The type of memory.
    public let type: String?

    /// Tags on the memory.
    public let tags: [String]?

    /// Metadata on the memory.
    public let metadata: [String: JSONValue]?

    /// The date the memory was created.
    public let createdAt: Date?
}

/// Knowledge graph data returned with search or query results.
public struct GraphData: Decodable, Sendable {
    /// Nodes in the knowledge graph.
    public let nodes: [GraphNode]?

    /// Edges connecting nodes in the knowledge graph.
    public let edges: [GraphEdge]?
}

/// A node in the knowledge graph.
public struct GraphNode: Decodable, Sendable {
    /// The node ID.
    public let id: String?

    /// The label or name of the node.
    public let label: String?

    /// The type of node.
    public let type: String?

    /// Additional properties.
    public let properties: [String: JSONValue]?
}

/// An edge in the knowledge graph.
public struct GraphEdge: Decodable, Sendable {
    /// The source node ID.
    public let source: String?

    /// The target node ID.
    public let target: String?

    /// The relationship label.
    public let label: String?

    /// The type of relationship.
    public let type: String?
}

// MARK: - Request Bodies

/// Request body for a hybrid search.
struct SearchRequest: Encodable {
    let query: String
    var limit: Int?
    var scoreThreshold: Double?
    var includeGraph: Bool?
    var filters: QueryFilters?
    var userId: String?
}
