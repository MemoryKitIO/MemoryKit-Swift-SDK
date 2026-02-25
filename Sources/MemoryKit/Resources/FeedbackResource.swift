import Foundation

/// Resource for submitting feedback on MemoryKit responses.
public struct FeedbackResource: Sendable {

    private let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    /// Submits feedback for a previous query or chat response.
    ///
    /// - Parameters:
    ///   - requestId: The request ID from a query or chat response (required).
    ///   - rating: The rating value (e.g., 1-5, or "thumbs_up"/"thumbs_down").
    ///   - comment: An optional comment.
    /// - Returns: The feedback response.
    @discardableResult
    public func submit(
        requestId: String,
        rating: JSONValue? = nil,
        comment: String? = nil
    ) async throws -> FeedbackResponse {
        let body = CreateFeedbackRequest(
            requestId: requestId,
            rating: rating,
            comment: comment
        )
        return try await client.post(path: "/feedback", body: body)
    }
}
