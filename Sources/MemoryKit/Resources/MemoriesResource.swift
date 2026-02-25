import Foundation

/// Resource for interacting with the Memories API.
public struct MemoriesResource: Sendable {

    private let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    // MARK: - CRUD

    /// Creates a new memory.
    ///
    /// - Parameters:
    ///   - content: The content of the memory (required).
    ///   - title: An optional title.
    ///   - type: The type of memory.
    ///   - tags: Tags to associate with the memory.
    ///   - metadata: Arbitrary key-value metadata.
    ///   - userId: The user ID to associate with this memory.
    ///   - language: The language of the content.
    ///   - format: The format of the content.
    /// - Returns: The created memory.
    @discardableResult
    public func create(
        content: String,
        title: String? = nil,
        type: String? = nil,
        tags: [String]? = nil,
        metadata: [String: JSONValue]? = nil,
        userId: String? = nil,
        language: String? = nil,
        format: String? = nil
    ) async throws -> Memory {
        let body = CreateMemoryRequest(
            content: content,
            title: title,
            type: type,
            tags: tags,
            metadata: metadata,
            userId: userId,
            language: language,
            format: format
        )
        return try await client.post(path: "/memories", body: body)
    }

    /// Batch ingest up to 100 memories at once.
    ///
    /// - Parameters:
    ///   - items: The memory items to ingest (max 100).
    ///   - defaults: Default values applied to all items.
    /// - Returns: A response with the created IDs and any errors.
    public func batchCreate(
        items: [BatchMemoryItem],
        defaults: BatchDefaults? = nil
    ) async throws -> BatchIngestResponse {
        let body = BatchIngestRequest(items: items, defaults: defaults)
        return try await client.post(path: "/memories/batch", body: body)
    }

    /// Lists memories with cursor-based pagination.
    ///
    /// - Parameters:
    ///   - limit: Maximum number of results per page. Defaults to 20.
    ///   - cursor: A cursor for pagination from a previous response.
    ///   - status: Filter by processing status.
    ///   - type: Filter by memory type.
    ///   - userId: Filter by user ID.
    /// - Returns: A paginated list of memories.
    public func list(
        limit: Int? = nil,
        cursor: String? = nil,
        status: String? = nil,
        type: String? = nil,
        userId: String? = nil
    ) async throws -> ListResponse<Memory> {
        var queryItems = [URLQueryItem]()
        if let limit = limit { queryItems.append(URLQueryItem(name: "limit", value: String(limit))) }
        if let cursor = cursor { queryItems.append(URLQueryItem(name: "cursor", value: cursor)) }
        if let status = status { queryItems.append(URLQueryItem(name: "status", value: status)) }
        if let type = type { queryItems.append(URLQueryItem(name: "type", value: type)) }
        if let userId = userId { queryItems.append(URLQueryItem(name: "userId", value: userId)) }

        return try await client.get(path: "/memories", queryItems: queryItems.isEmpty ? nil : queryItems)
    }

    /// Retrieves a single memory by ID.
    ///
    /// - Parameter id: The memory ID.
    /// - Returns: The memory.
    public func get(_ id: String) async throws -> Memory {
        return try await client.get(path: "/memories/\(id)")
    }

    /// Updates an existing memory.
    ///
    /// - Parameters:
    ///   - id: The memory ID.
    ///   - title: Updated title.
    ///   - type: Updated type.
    ///   - tags: Updated tags.
    ///   - metadata: Updated metadata.
    ///   - content: Updated content.
    /// - Returns: The updated memory.
    @discardableResult
    public func update(
        _ id: String,
        title: String? = nil,
        type: String? = nil,
        tags: [String]? = nil,
        metadata: [String: JSONValue]? = nil,
        content: String? = nil
    ) async throws -> Memory {
        let body = UpdateMemoryRequest(
            title: title,
            type: type,
            tags: tags,
            metadata: metadata,
            content: content
        )
        return try await client.put(path: "/memories/\(id)", body: body)
    }

    /// Uploads a file as a memory. Supports PDF, TXT, Markdown, HTML, JSON, and CSV.
    ///
    /// - Parameters:
    ///   - fileData: The file contents as `Data`.
    ///   - fileName: The file name (e.g., "document.pdf").
    ///   - mimeType: The MIME type (e.g., "application/pdf").
    ///   - title: An optional title for the memory.
    ///   - tags: Tags to associate with the memory.
    ///   - metadata: Arbitrary key-value metadata.
    ///   - userId: The user ID to associate with this memory.
    /// - Returns: The created memory.
    @discardableResult
    public func upload(
        fileData: Data,
        fileName: String,
        mimeType: String = "application/octet-stream",
        title: String? = nil,
        tags: [String]? = nil,
        metadata: [String: JSONValue]? = nil,
        userId: String? = nil
    ) async throws -> Memory {
        var fields = [String: String]()
        if let title { fields["title"] = title }
        if let tags { fields["tags"] = tags.joined(separator: ",") }
        if let userId { fields["userId"] = userId }
        if let metadata,
           let metadataData = try? JSONEncoder().encode(metadata),
           let metadataString = String(data: metadataData, encoding: .utf8) {
            fields["metadata"] = metadataString
        }

        return try await client.postMultipart(
            path: "/memories/upload",
            fileData: fileData,
            fileName: fileName,
            mimeType: mimeType,
            fields: fields
        )
    }

    /// Triggers reprocessing of an existing memory (re-chunk, re-embed).
    ///
    /// - Parameter id: The memory ID.
    /// - Returns: The updated memory.
    @discardableResult
    public func reprocess(_ id: String) async throws -> Memory {
        return try await client.post(path: "/memories/\(id)/reprocess", body: EmptyBody())
    }

    /// Deletes a memory by ID.
    ///
    /// - Parameter id: The memory ID.
    public func delete(_ id: String) async throws {
        try await client.delete(path: "/memories/\(id)")
    }

    // MARK: - Query & Search

    /// Performs a RAG query against your memories.
    ///
    /// - Parameters:
    ///   - query: The natural language query (required).
    ///   - maxSources: Maximum number of source memories to reference.
    ///   - temperature: The LLM temperature for generation.
    ///   - mode: Query mode (e.g., "balanced", "precise", "creative").
    ///   - userId: Scope the query to a specific user's memories.
    ///   - instructions: Additional instructions for the LLM.
    ///   - responseFormat: The desired response format.
    ///   - includeGraph: Whether to include knowledge graph data.
    ///   - filters: Filters to apply to the query.
    /// - Returns: A query response with an answer, sources, and usage.
    public func query(
        query: String,
        maxSources: Int? = nil,
        temperature: Double? = nil,
        mode: String? = nil,
        userId: String? = nil,
        instructions: String? = nil,
        responseFormat: String? = nil,
        includeGraph: Bool? = nil,
        filters: QueryFilters? = nil
    ) async throws -> QueryResponse {
        let body = QueryRequest(
            query: query,
            maxSources: maxSources,
            temperature: temperature,
            mode: mode,
            userId: userId,
            instructions: instructions,
            responseFormat: responseFormat,
            includeGraph: includeGraph,
            filters: filters
        )
        return try await client.post(path: "/memories/query", body: body)
    }

    /// Performs a hybrid search across your memories.
    ///
    /// - Parameters:
    ///   - query: The search query.
    ///   - limit: Maximum number of results.
    ///   - scoreThreshold: Minimum relevance score threshold.
    ///   - includeGraph: Whether to include knowledge graph data.
    ///   - filters: Filters to apply to the search.
    ///   - userId: Scope the search to a specific user's memories.
    /// - Returns: Search results with optional graph data.
    public func search(
        query: String,
        limit: Int? = nil,
        scoreThreshold: Double? = nil,
        includeGraph: Bool? = nil,
        filters: QueryFilters? = nil,
        userId: String? = nil
    ) async throws -> SearchResponse {
        let body = SearchRequest(
            query: query,
            limit: limit,
            scoreThreshold: scoreThreshold,
            includeGraph: includeGraph,
            filters: filters,
            userId: userId
        )
        return try await client.post(path: "/memories/search", body: body)
    }

    // MARK: - Streaming

    /// Streams a RAG query response as server-sent events.
    ///
    /// - Parameters:
    ///   - query: The natural language query (required).
    ///   - maxSources: Maximum number of source memories to reference.
    ///   - temperature: The LLM temperature for generation.
    ///   - mode: Query mode (e.g., "balanced", "precise", "creative").
    ///   - userId: Scope the query to a specific user's memories.
    ///   - instructions: Additional instructions for the LLM.
    ///   - responseFormat: The desired response format.
    ///   - includeGraph: Whether to include knowledge graph data.
    ///   - filters: Filters to apply to the query.
    /// - Returns: An `AsyncSequence` of SSE events.
    public func stream(
        query: String,
        maxSources: Int? = nil,
        temperature: Double? = nil,
        mode: String? = nil,
        userId: String? = nil,
        instructions: String? = nil,
        responseFormat: String? = nil,
        includeGraph: Bool? = nil,
        filters: QueryFilters? = nil
    ) async throws -> SSEStream {
        let body = StreamRequest(
            query: query,
            maxSources: maxSources,
            temperature: temperature,
            mode: mode,
            userId: userId,
            instructions: instructions,
            responseFormat: responseFormat,
            includeGraph: includeGraph,
            filters: filters
        )
        let (bytes, _) = try await client.postStream(path: "/memories/stream", body: body)
        return SSEStream(bytes: bytes)
    }
}
