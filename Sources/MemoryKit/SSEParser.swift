import Foundation

/// An SSE event parsed from a server-sent events stream.
public struct SSEEvent: Sendable {
    /// The event type (e.g., "text", "sources", "usage", "done", "error").
    public let event: String

    /// The raw data string of the event.
    public let data: String

    /// The optional event ID.
    public let id: String?

    /// Decodes the data field as a specific type.
    public func decode<T: Decodable>(_ type: T.self, decoder: JSONDecoder = .init()) throws -> T {
        guard let jsonData = data.data(using: .utf8) else {
            throw MemoryKitError.decodingError(
                DecodingError.dataCorrupted(.init(
                    codingPath: [],
                    debugDescription: "SSE data is not valid UTF-8"
                ))
            )
        }
        do {
            let dec = JSONDecoder()
            dec.keyDecodingStrategy = .convertFromSnakeCase
            return try dec.decode(type, from: jsonData)
        } catch {
            throw MemoryKitError.decodingError(error)
        }
    }
}

/// An AsyncSequence that parses SSE events from a URLSession byte stream.
public struct SSEStream: AsyncSequence, Sendable {
    public typealias Element = SSEEvent

    private let bytes: URLSession.AsyncBytes

    init(bytes: URLSession.AsyncBytes) {
        self.bytes = bytes
    }

    public func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(lines: bytes.lines)
    }

    public struct AsyncIterator: AsyncIteratorProtocol {
        private var lines: AsyncLineSequence<URLSession.AsyncBytes>.AsyncIterator
        private var currentEvent: String?
        private var currentData: [String] = []
        private var currentId: String?

        init(lines: AsyncLineSequence<URLSession.AsyncBytes>) {
            self.lines = lines.makeAsyncIterator()
        }

        public mutating func next() async throws -> SSEEvent? {
            while let line = try await lines.next() {
                // Empty line signals end of an event
                if line.isEmpty {
                    if !currentData.isEmpty {
                        let event = SSEEvent(
                            event: currentEvent ?? "message",
                            data: currentData.joined(separator: "\n"),
                            id: currentId
                        )
                        currentEvent = nil
                        currentData = []
                        currentId = nil
                        return event
                    }
                    continue
                }

                // Comment lines start with ':'
                if line.hasPrefix(":") {
                    continue
                }

                // Parse field
                let field: String
                let value: String

                if let colonIndex = line.firstIndex(of: ":") {
                    field = String(line[line.startIndex..<colonIndex])
                    let valueStart = line.index(after: colonIndex)
                    if valueStart < line.endIndex && line[valueStart] == " " {
                        value = String(line[line.index(after: valueStart)...])
                    } else {
                        value = String(line[valueStart...])
                    }
                } else {
                    field = line
                    value = ""
                }

                switch field {
                case "event":
                    currentEvent = value
                case "data":
                    currentData.append(value)
                case "id":
                    currentId = value.isEmpty ? nil : value
                default:
                    break
                }
            }

            // End of stream - emit any remaining event
            if !currentData.isEmpty {
                let event = SSEEvent(
                    event: currentEvent ?? "message",
                    data: currentData.joined(separator: "\n"),
                    id: currentId
                )
                currentData = []
                currentEvent = nil
                currentId = nil
                return event
            }

            return nil
        }
    }
}
