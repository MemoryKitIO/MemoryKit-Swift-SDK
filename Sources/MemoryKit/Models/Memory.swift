import Foundation

/// A memory stored in MemoryKit.
public struct Memory: Codable, Sendable, Identifiable {
    /// Unique identifier for the memory.
    public let id: String

    /// The content of the memory.
    public let content: String?

    /// An optional title for the memory.
    public let title: String?

    /// The type of memory (e.g., "note", "document").
    public let type: String?

    /// Tags associated with the memory.
    public let tags: [String]?

    /// Arbitrary metadata associated with the memory.
    public let metadata: [String: JSONValue]?

    /// The user ID that owns this memory.
    public let userId: String?

    /// The language of the content.
    public let language: String?

    /// The format of the content.
    public let format: String?

    /// The processing status of the memory.
    public let status: String?

    /// The number of chunks created from this memory.
    public let chunksCount: Int?

    /// The date the memory was created.
    public let createdAt: Date?

    /// The date the memory was last updated.
    public let updatedAt: Date?
}

// MARK: - Request Bodies

/// Request body for creating a memory.
struct CreateMemoryRequest: Encodable {
    let content: String
    var title: String?
    var type: String?
    var tags: [String]?
    var metadata: [String: JSONValue]?
    var userId: String?
    var language: String?
    var format: String?
}

/// Request body for updating a memory.
struct UpdateMemoryRequest: Encodable {
    var title: String?
    var type: String?
    var tags: [String]?
    var metadata: [String: JSONValue]?
    var content: String?
}

/// A single item in a batch ingest request.
public struct BatchMemoryItem: Encodable, Sendable {
    public let content: String
    public var title: String?
    public var type: String?
    public var tags: [String]?
    public var metadata: [String: JSONValue]?
    public var userId: String?
    public var language: String?
    public var format: String?

    public init(
        content: String,
        title: String? = nil,
        type: String? = nil,
        tags: [String]? = nil,
        metadata: [String: JSONValue]? = nil,
        userId: String? = nil,
        language: String? = nil,
        format: String? = nil
    ) {
        self.content = content
        self.title = title
        self.type = type
        self.tags = tags
        self.metadata = metadata
        self.userId = userId
        self.language = language
        self.format = format
    }
}

/// Default values applied to all items in a batch ingest.
public struct BatchDefaults: Encodable, Sendable {
    public var type: String?
    public var tags: [String]?
    public var metadata: [String: JSONValue]?
    public var userId: String?
    public var language: String?
    public var format: String?

    public init(
        type: String? = nil,
        tags: [String]? = nil,
        metadata: [String: JSONValue]? = nil,
        userId: String? = nil,
        language: String? = nil,
        format: String? = nil
    ) {
        self.type = type
        self.tags = tags
        self.metadata = metadata
        self.userId = userId
        self.language = language
        self.format = format
    }
}

/// Request body for batch ingest.
struct BatchIngestRequest: Encodable {
    let items: [BatchMemoryItem]
    var defaults: BatchDefaults?
}

/// A single item result from batch ingestion.
public struct BatchMemoryResult: Decodable, Sendable {
    /// The ID of the created memory.
    public let id: String

    /// The title of the memory.
    public let title: String?

    /// The processing status.
    public let status: String?

    /// The index in the original batch.
    public let index: Int?
}

/// Response from a batch ingest operation.
public struct BatchIngestResponse: Decodable, Sendable {
    /// The created memory items.
    public let items: [BatchMemoryResult]?

    /// Total number of items processed.
    public let total: Int?

    /// The number of items that failed.
    public let failed: Int?

    /// Error details for failed items.
    public let errors: [BatchError]?
}

/// An error for a single item in a batch operation.
public struct BatchError: Decodable, Sendable {
    /// The index of the failed item.
    public let index: Int?

    /// The error description.
    public let error: String?

    /// The error message (legacy).
    public let message: String?
}
