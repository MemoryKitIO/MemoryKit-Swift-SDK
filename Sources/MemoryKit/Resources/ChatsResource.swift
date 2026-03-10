import Foundation

// V2: Chats resource disabled for initial launch.
// The entire chats API (create, list, getHistory, sendMessage, streamMessage, delete)
// will be re-enabled when the LLM-powered chat endpoints are available.

// public struct ChatsResource: Sendable {
//
//     private let client: HTTPClient
//
//     init(client: HTTPClient) {
//         self.client = client
//     }
//
//     // MARK: - CRUD
//
//     @discardableResult
//     public func create(
//         userId: String? = nil,
//         title: String? = nil,
//         metadata: [String: JSONValue]? = nil
//     ) async throws -> Chat {
//         let body = CreateChatRequest(
//             userId: userId,
//             title: title,
//             metadata: metadata
//         )
//         return try await client.post(path: "/chats", body: body)
//     }
//
//     public func list(
//         userId: String? = nil,
//         limit: Int? = nil,
//         cursor: String? = nil
//     ) async throws -> ListResponse<Chat> {
//         var queryItems = [URLQueryItem]()
//         if let userId = userId { queryItems.append(URLQueryItem(name: "userId", value: userId)) }
//         if let limit = limit { queryItems.append(URLQueryItem(name: "limit", value: String(limit))) }
//         if let cursor = cursor { queryItems.append(URLQueryItem(name: "cursor", value: cursor)) }
//         return try await client.get(path: "/chats", queryItems: queryItems.isEmpty ? nil : queryItems)
//     }
//
//     public func getHistory(_ id: String) async throws -> ChatWithMessages {
//         return try await client.get(path: "/chats/\(id)/messages")
//     }
//
//     public func sendMessage(
//         _ id: String,
//         message: String,
//         mode: String? = nil
//     ) async throws -> ChatMessageResponse {
//         let body = SendMessageRequest(message: message, mode: mode)
//         return try await client.post(path: "/chats/\(id)/messages", body: body)
//     }
//
//     public func streamMessage(
//         _ id: String,
//         message: String,
//         mode: String? = nil
//     ) async throws -> SSEStream {
//         let body = SendMessageRequest(message: message, mode: mode)
//         let (bytes, _) = try await client.postStream(path: "/chats/\(id)/messages/stream", body: body)
//         return SSEStream(bytes: bytes)
//     }
//
//     public func delete(_ id: String) async throws {
//         try await client.delete(path: "/chats/\(id)")
//     }
// }
