import Foundation

/// Internal HTTP client that wraps URLSession with retry logic and authentication.
final class HTTPClient: Sendable {

    private let session: URLSession
    private let configuration: Configuration

    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)

            // Try ISO 8601 with fractional seconds first
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = isoFormatter.date(from: string) {
                return date
            }

            // Fall back to ISO 8601 without fractional seconds
            isoFormatter.formatOptions = [.withInternetDateTime]
            if let date = isoFormatter.date(from: string) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot decode date from: \(string)"
            )
        }
        return decoder
    }()

    init(configuration: Configuration) {
        self.configuration = configuration

        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = configuration.timeoutInterval
        sessionConfig.httpAdditionalHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer \(configuration.apiKey)",
            "User-Agent": "MemoryKit-Swift/1.0.0"
        ]
        self.session = URLSession(configuration: sessionConfig)
    }

    // MARK: - HTTP Methods

    /// Performs a GET request and decodes the response.
    func get<T: Decodable>(
        path: String,
        queryItems: [URLQueryItem]? = nil
    ) async throws -> T {
        let request = try buildRequest(method: "GET", path: path, queryItems: queryItems)
        return try await executeWithRetry(request)
    }

    /// Performs a POST request with a body and decodes the response.
    func post<B: Encodable, T: Decodable>(
        path: String,
        body: B
    ) async throws -> T {
        var request = try buildRequest(method: "POST", path: path)
        request.httpBody = try encodeBody(body)
        return try await executeWithRetry(request)
    }

    /// Performs a POST request with a body, expecting no response body (e.g., 202/204).
    func postNoContent<B: Encodable>(
        path: String,
        body: B
    ) async throws {
        var request = try buildRequest(method: "POST", path: path)
        request.httpBody = try encodeBody(body)
        try await executeNoContentWithRetry(request)
    }

    /// Performs a PUT request with a body and decodes the response.
    func put<B: Encodable, T: Decodable>(
        path: String,
        body: B
    ) async throws -> T {
        var request = try buildRequest(method: "PUT", path: path)
        request.httpBody = try encodeBody(body)
        return try await executeWithRetry(request)
    }

    /// Performs a DELETE request with no response body.
    func delete(
        path: String,
        queryItems: [URLQueryItem]? = nil
    ) async throws {
        let request = try buildRequest(method: "DELETE", path: path, queryItems: queryItems)
        try await executeNoContentWithRetry(request)
    }

    /// Performs a POST request and returns the raw bytes stream for SSE.
    func postStream<B: Encodable>(
        path: String,
        body: B
    ) async throws -> (URLSession.AsyncBytes, URLResponse) {
        var request = try buildRequest(method: "POST", path: path)
        request.httpBody = try encodeBody(body)
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")

        let (bytes, response) = try await session.bytes(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw MemoryKitError.networkError(
                URLError(.badServerResponse, userInfo: [NSLocalizedDescriptionKey: "Invalid response type"])
            )
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            // Collect error body from stream
            var errorData = Data()
            for try await byte in bytes {
                errorData.append(byte)
                if errorData.count > 4096 { break }
            }
            throw parseError(statusCode: httpResponse.statusCode, data: errorData)
        }

        return (bytes, response)
    }

    /// Performs a multipart/form-data POST request and decodes the response.
    func postMultipart<T: Decodable>(
        path: String,
        fileData: Data,
        fileName: String,
        mimeType: String,
        fields: [String: String] = [:]
    ) async throws -> T {
        let boundary = "MemoryKit-\(UUID().uuidString)"
        var request = try buildRequest(method: "POST", path: path)
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        // Add text fields
        for (key, value) in fields {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        // Add file
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n".data(using: .utf8)!)

        // Close boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body
        return try await executeWithRetry(request)
    }

    // MARK: - Internals

    /// Access the decoder for use by resources.
    var jsonDecoder: JSONDecoder { decoder }

    private func buildRequest(
        method: String,
        path: String,
        queryItems: [URLQueryItem]? = nil
    ) throws -> URLRequest {
        var components = URLComponents(url: configuration.baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: true)

        if let queryItems = queryItems, !queryItems.isEmpty {
            components?.queryItems = queryItems
        }

        guard let url = components?.url else {
            throw MemoryKitError.invalidURL(path)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        return request
    }

    private func encodeBody<B: Encodable>(_ body: B) throws -> Data {
        do {
            return try encoder.encode(body)
        } catch {
            throw MemoryKitError.encodingError(error)
        }
    }

    private func executeWithRetry<T: Decodable>(_ request: URLRequest) async throws -> T {
        var lastError: MemoryKitError?
        let maxAttempts = configuration.maxRetries + 1

        for attempt in 1...maxAttempts {
            do {
                let (data, response) = try await performRequest(request)
                return try decodeResponse(data: data, response: response)
            } catch let error as MemoryKitError {
                lastError = error
                if error.isRetryable && attempt < maxAttempts {
                    let delay = retryDelay(attempt: attempt, response: nil)
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    continue
                }
                throw error
            } catch {
                throw MemoryKitError.networkError(error)
            }
        }

        throw lastError ?? MemoryKitError.networkError(
            URLError(.unknown, userInfo: [NSLocalizedDescriptionKey: "Unknown error after retries"])
        )
    }

    private func executeNoContentWithRetry(_ request: URLRequest) async throws {
        var lastError: MemoryKitError?
        let maxAttempts = configuration.maxRetries + 1

        for attempt in 1...maxAttempts {
            do {
                let (data, response) = try await performRequest(request)

                guard let httpResponse = response as? HTTPURLResponse else {
                    throw MemoryKitError.networkError(
                        URLError(.badServerResponse, userInfo: [NSLocalizedDescriptionKey: "Invalid response type"])
                    )
                }

                guard (200..<300).contains(httpResponse.statusCode) else {
                    let error = parseError(statusCode: httpResponse.statusCode, data: data)
                    if error.isRetryable && attempt < maxAttempts {
                        let delay = retryDelay(attempt: attempt, response: httpResponse)
                        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                        lastError = error
                        continue
                    }
                    throw error
                }

                return
            } catch let error as MemoryKitError {
                lastError = error
                if error.isRetryable && attempt < maxAttempts {
                    let delay = retryDelay(attempt: attempt, response: nil)
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    continue
                }
                throw error
            } catch {
                throw MemoryKitError.networkError(error)
            }
        }

        throw lastError ?? MemoryKitError.networkError(
            URLError(.unknown, userInfo: [NSLocalizedDescriptionKey: "Unknown error after retries"])
        )
    }

    private func performRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(for: request)
        } catch {
            throw MemoryKitError.networkError(error)
        }
    }

    private func decodeResponse<T: Decodable>(data: Data, response: URLResponse) throws -> T {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw MemoryKitError.networkError(
                URLError(.badServerResponse, userInfo: [NSLocalizedDescriptionKey: "Invalid response type"])
            )
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw parseError(statusCode: httpResponse.statusCode, data: data)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw MemoryKitError.decodingError(error)
        }
    }

    private func parseError(statusCode: Int, data: Data) -> MemoryKitError {
        if let errorResponse = try? decoder.decode(APIErrorResponse.self, from: data) {
            return .requestFailed(
                statusCode: statusCode,
                code: errorResponse.resolvedCode,
                message: errorResponse.resolvedMessage
            )
        }

        let message = String(data: data, encoding: .utf8) ?? "Unknown error"
        return .requestFailed(statusCode: statusCode, code: nil, message: message)
    }

    private func retryDelay(attempt: Int, response: HTTPURLResponse?) -> TimeInterval {
        // Check for Retry-After header
        if let retryAfter = response?.value(forHTTPHeaderField: "Retry-After"),
           let seconds = Double(retryAfter) {
            return seconds
        }

        // Exponential backoff with jitter
        let base = configuration.retryBaseDelay
        let exponential = base * pow(2.0, Double(attempt - 1))
        let jitter = Double.random(in: 0...(exponential * 0.1))
        return min(exponential + jitter, 30.0)
    }
}
