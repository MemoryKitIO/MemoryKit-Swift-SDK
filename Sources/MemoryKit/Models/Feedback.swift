import Foundation

/// A feedback submission to MemoryKit.
public struct Feedback: Codable, Sendable {
    /// The request ID this feedback is for.
    public let requestId: String

    /// The rating (e.g., 1-5 or thumbs up/down).
    public let rating: JSONValue?

    /// An optional comment.
    public let comment: String?
}

/// Response from submitting feedback.
public struct FeedbackResponse: Decodable, Sendable {
    /// Whether the feedback was accepted.
    public let success: Bool?

    /// A feedback ID.
    public let id: String?

    /// A message from the API.
    public let message: String?
}

// MARK: - Request Bodies

/// Request body for submitting feedback.
struct CreateFeedbackRequest: Encodable {
    let requestId: String
    var rating: JSONValue?
    var comment: String?
}
