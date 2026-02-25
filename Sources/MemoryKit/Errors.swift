import Foundation

/// Errors thrown by the MemoryKit SDK.
public enum MemoryKitError: Error, Sendable {

    /// The API returned an error response.
    ///
    /// - Parameters:
    ///   - statusCode: The HTTP status code.
    ///   - code: An optional machine-readable error code from the API.
    ///   - message: A human-readable error message.
    case requestFailed(statusCode: Int, code: String?, message: String)

    /// A network-level error occurred (e.g., no connectivity).
    case networkError(Error)

    /// Failed to decode the API response.
    case decodingError(Error)

    /// Failed to encode the request body.
    case encodingError(Error)

    /// The request URL could not be constructed.
    case invalidURL(String)

    /// An SSE stream encountered an error.
    case streamError(String)
}

// MARK: - Convenience Properties

extension MemoryKitError {

    /// Whether this error is an authentication error (401).
    public var isAuthError: Bool {
        if case .requestFailed(let statusCode, _, _) = self {
            return statusCode == 401
        }
        return false
    }

    /// Whether the request was rate limited (429).
    public var isRateLimited: Bool {
        if case .requestFailed(let statusCode, _, _) = self {
            return statusCode == 429
        }
        return false
    }

    /// Whether this is a server error (5xx).
    public var isServerError: Bool {
        if case .requestFailed(let statusCode, _, _) = self {
            return statusCode >= 500 && statusCode < 600
        }
        return false
    }

    /// Whether this error is a not found error (404).
    public var isNotFound: Bool {
        if case .requestFailed(let statusCode, _, _) = self {
            return statusCode == 404
        }
        return false
    }

    /// Whether this error is a validation error (400 or 422).
    public var isValidationError: Bool {
        if case .requestFailed(let statusCode, _, _) = self {
            return statusCode == 400 || statusCode == 422
        }
        return false
    }

    /// Whether the error is retryable (429 or 5xx).
    public var isRetryable: Bool {
        return isRateLimited || isServerError
    }

    /// The HTTP status code, if this is a request error.
    public var statusCode: Int? {
        if case .requestFailed(let statusCode, _, _) = self {
            return statusCode
        }
        return nil
    }
}

// MARK: - LocalizedError

extension MemoryKitError: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case .requestFailed(let statusCode, let code, let message):
            if let code = code {
                return "MemoryKit API error \(statusCode) (\(code)): \(message)"
            }
            return "MemoryKit API error \(statusCode): \(message)"
        case .networkError(let error):
            return "MemoryKit network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "MemoryKit decoding error: \(error.localizedDescription)"
        case .encodingError(let error):
            return "MemoryKit encoding error: \(error.localizedDescription)"
        case .invalidURL(let url):
            return "MemoryKit invalid URL: \(url)"
        case .streamError(let message):
            return "MemoryKit stream error: \(message)"
        }
    }
}

// MARK: - API Error Response

/// The error body returned by the MemoryKit API.
struct APIErrorResponse: Decodable, Sendable {
    let error: APIErrorDetail?
    let message: String?
    let code: String?

    struct APIErrorDetail: Decodable, Sendable {
        let code: String?
        let message: String?
    }

    /// Resolves the error message from the response.
    var resolvedMessage: String {
        return error?.message ?? message ?? "Unknown error"
    }

    /// Resolves the error code from the response.
    var resolvedCode: String? {
        return error?.code ?? code
    }
}
