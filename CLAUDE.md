# MemoryKit Swift SDK

Official Swift SDK for MemoryKit RAG API. Zero dependencies, async/await, Sendable-safe.

## Quick Commands
```bash
swift build             # Build debug
swift build -c release  # Build release
swift test              # Run tests (when available)
swift package resolve   # Resolve dependencies
```

## Architecture

```
Sources/MemoryKit/
├── MemoryKit.swift           # Entry point — public init, holds resources
├── Configuration.swift       # Configuration struct (apiKey, baseURL, timeout, retries)
├── HTTPClient.swift          # URLSession wrapper with retry, auth, multipart upload
├── Errors.swift              # MemoryKitError enum (requestFailed, networkError, etc.)
├── SSEParser.swift           # SSEStream (AsyncSequence) + SSEEvent for streaming
├── Models/                   # Codable structs
│   ├── Memory.swift          # Memory, MemoryList, CreateMemoryParams
│   ├── Chat.swift            # Chat, ChatList, ChatMessage, etc.
│   ├── User.swift            # User, UserList
│   ├── Event.swift           # Event, EventList
│   ├── Webhook.swift         # Webhook, WebhookList, WebhookTestResponse
│   ├── Query.swift           # QueryParams, QueryResponse, QuerySource
│   ├── Search.swift          # SearchParams, SearchResponse, SearchResult
│   ├── Status.swift          # StatusResponse, UsageInfo
│   ├── Feedback.swift        # FeedbackParams, FeedbackResponse
│   └── Common.swift          # JSONValue, PaginatedResponse, etc.
└── Resources/                # One file per API resource
    ├── MemoriesResource.swift  # CRUD + search + query + stream + upload + reprocess
    ├── ChatsResource.swift     # CRUD + sendMessage + streamMessage + history
    ├── UsersResource.swift     # CRUD + events
    ├── WebhooksResource.swift  # CRUD + test
    ├── FeedbackResource.swift  # create()
    └── StatusResource.swift    # get()
```

## Conventions

- **async/await**: All public methods are `async throws`
- **Sendable**: All public types conform to `Sendable` for concurrency safety
- **Codable + snake_case**: Models use `Codable`, HTTPClient uses `keyDecodingStrategy: .convertFromSnakeCase`
- **URLSession-only**: Zero external dependencies, uses Foundation `URLSession`
- **Resource pattern**: Each resource holds a reference to `HTTPClient`, methods map 1:1 to API
- **SSE streaming**: `SSEStream` is an `AsyncSequence` built on `URLSession.AsyncBytes`
- **Multipart upload**: `HTTPClient.postMultipart()` builds form-data with boundary
- **Platform support**: iOS 15+, macOS 12+, watchOS 8+, tvOS 15+

## API → SDK Method Mapping

| API Endpoint | SDK Method |
|---|---|
| `POST /v1/memories` | `mk.memories.create()` |
| `GET /v1/memories` | `mk.memories.list()` |
| `GET /v1/memories/:id` | `mk.memories.get()` |
| `PUT /v1/memories/:id` | `mk.memories.update()` |
| `DELETE /v1/memories/:id` | `mk.memories.delete()` |
| `GET /v1/memories/search` | `mk.memories.search()` |
| `POST /v1/memories/query` | `mk.memories.query()` |
| `POST /v1/memories/query/stream` | `mk.memories.stream()` |
| `POST /v1/memories/upload` | `mk.memories.upload()` |
| `POST /v1/memories/:id/reprocess` | `mk.memories.reprocess()` |
| `POST /v1/chats` | `mk.chats.create()` |
| `GET /v1/chats` | `mk.chats.list()` |
| `GET /v1/chats/:id` | `mk.chats.get()` |
| `DELETE /v1/chats/:id` | `mk.chats.delete()` |
| `POST /v1/chats/:id/messages` | `mk.chats.sendMessage()` |
| `POST /v1/chats/:id/messages/stream` | `mk.chats.streamMessage()` |
| `GET /v1/chats/:id/history` | `mk.chats.getHistory()` |
| `POST /v1/users` | `mk.users.upsert()` |
| `GET /v1/users/:id` | `mk.users.get()` |
| `PUT /v1/users/:id` | `mk.users.update()` |
| `DELETE /v1/users/:id` | `mk.users.delete()` |
| `POST /v1/users/:id/events` | `mk.users.createEvent()` |
| `GET /v1/users/:id/events` | `mk.users.listEvents()` |
| `DELETE /v1/users/:id/events/:eid` | `mk.users.deleteEvent()` |
| `POST /v1/webhooks` | `mk.webhooks.create()` |
| `GET /v1/webhooks` | `mk.webhooks.list()` |
| `GET /v1/webhooks/:id` | `mk.webhooks.get()` |
| `DELETE /v1/webhooks/:id` | `mk.webhooks.delete()` |
| `POST /v1/webhooks/:id/test` | `mk.webhooks.test()` |
| `GET /v1/status` | `mk.status.get()` |
| `POST /v1/feedback` | `mk.feedback.create()` |

## Adding a New Method

1. Add `Codable` structs to the model file in `Models/`
2. Add `public func ... async throws` to the resource in `Resources/`
3. Run `swift build` to verify
4. Update README.md

## Testing (TODO)

Currently 0% test coverage. Test target configured in Package.swift at `Tests/MemoryKitTests/`.
