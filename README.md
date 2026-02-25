# MemoryKit Swift SDK

Official Swift SDK for [MemoryKit](https://memorykit.io) — the memory layer for AI applications.

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/platforms-iOS%2015%20%7C%20macOS%2012%20%7C%20watchOS%208%20%7C%20tvOS%2015-333333.svg)](https://developer.apple.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## Installation

### Swift Package Manager

Add MemoryKit to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/MemoryKitIO/MemoryKit-Swift-SDK.git", from: "0.1.1")
]
```

Or add it in Xcode via **File → Add Package Dependencies** and enter:

```
https://github.com/MemoryKitIO/MemoryKit-Swift-SDK.git
```

## Quick Start

```swift
import MemoryKit

let mk = MemoryKit(apiKey: "ctx_...")

// Store a memory
let memory = try await mk.memories.create(
    content: "The user prefers dark mode and metric units.",
    tags: ["preferences"]
)

// Query with RAG
let result = try await mk.memories.query(
    query: "What are the user's preferences?"
)

print(result.answer)
```

## Requirements

| Requirement | Minimum |
| --- | --- |
| iOS | 15.0+ |
| macOS | 12.0+ |
| watchOS | 8.0+ |
| tvOS | 15.0+ |
| Swift | 5.9+ |
| Xcode | 15.0+ |

**Zero external dependencies** — uses only Foundation/URLSession.

## Usage

### Memories

```swift
// Create
let memory = try await mk.memories.create(
    content: "Meeting notes from Q4 planning...",
    title: "Q4 Planning Notes",
    tags: ["planning", "q4"],
    userId: "user_123"
)

// List
let list = try await mk.memories.list(limit: 20, status: "completed")
for memory in list.data {
    print(memory.title ?? memory.id)
}

// Get
let mem = try await mk.memories.get("mem_abc123")

// Update
try await mk.memories.update("mem_abc123", title: "Updated Title")

// Search
let results = try await mk.memories.search(
    query: "quarterly revenue targets",
    limit: 10
)

// Query (RAG)
let answer = try await mk.memories.query(
    query: "Summarize our Q4 goals",
    mode: "balanced",
    maxSources: 5,
    instructions: "Be concise. Use bullet points."
)
print(answer.answer)
print(answer.sources.count, "sources used")

// Delete
try await mk.memories.delete("mem_abc123")
```

### Streaming

```swift
for try await event in mk.memories.stream(
    query: "What happened in our last meeting?",
    mode: "balanced"
) {
    switch event.event {
    case "text":
        if let content = event.data["content"] as? String {
            print(content, terminator: "")
        }
    case "sources":
        print("\nSources received")
    case "done":
        print("\n--- Stream complete ---")
    case "error":
        print("\nError:", event.data)
    default:
        break
    }
}
```

### Chats

```swift
// Create a chat
let chat = try await mk.chats.create(
    userId: "user_123",
    title: "Support Chat"
)

// Send a message
let response = try await mk.chats.sendMessage(
    chat.id,
    message: "How do I reset my password?",
    mode: "balanced"
)
print(response.message.content)

// Get history
let history = try await mk.chats.getHistory("chat_abc123")
for msg in history.messages {
    print("\(msg.role): \(msg.content)")
}

// Stream a message
for try await event in mk.chats.streamMessage(
    chat.id,
    message: "Can you explain in more detail?"
) {
    if event.event == "text", let content = event.data["content"] as? String {
        print(content, terminator: "")
    }
}

// List chats
let chats = try await mk.chats.list(userId: "user_123", limit: 20)

// Delete
try await mk.chats.delete("chat_abc123")
```

### Users

```swift
// Upsert user (create or update)
let user = try await mk.users.upsert(
    id: "user_123",
    name: "Alice",
    email: "alice@example.com",
    metadata: ["plan": "pro"]
)

// Get user
let u = try await mk.users.get("user_123")

// Update user
try await mk.users.update("user_123", name: "Alice Smith")

// Delete (keeps memories and chats)
try await mk.users.delete("user_123")

// Full GDPR erasure — delete user and all associated data
try await mk.users.delete("user_123", cascade: true)
```

### Events

```swift
// Track event
let event = try await mk.users.createEvent(
    "user_123",
    type: "page_view",
    data: ["page": "/settings"]
)

// List events
let events = try await mk.users.listEvents("user_123", limit: 20)

// Delete event
try await mk.users.deleteEvent("user_123", eventId: "evt_abc123")
```

### Webhooks

```swift
// Register webhook
let webhook = try await mk.webhooks.create(
    url: "https://example.com/webhook",
    events: ["memory.completed", "memory.failed"]
)
print("Secret:", webhook.secret ?? "")

// List webhooks
let webhooks = try await mk.webhooks.list()

// Test webhook
let testResult = try await mk.webhooks.test("whk_abc123")
print("Success:", testResult.success)

// Delete
try await mk.webhooks.delete("whk_abc123")
```

### Status

```swift
let status = try await mk.status.get()
print("Memories:", status.usage.memoriesTotal)
```

### Feedback

```swift
try await mk.feedback.create(
    requestId: "req_abc123",
    rating: 5,
    comment: "Great answer!"
)
```

## Error Handling

```swift
do {
    let result = try await mk.memories.query(query: "...")
    print(result.answer)
} catch let error as MemoryKitError {
    switch error {
    case .requestFailed(let statusCode, let code, let message):
        switch statusCode {
        case 401: print("Invalid API key")
        case 429: print("Rate limited — retry later")
        case 400: print("Bad request:", message ?? "")
        default: print("Error \(statusCode):", message ?? "")
        }
    case .networkError(let underlyingError):
        print("Network error:", underlyingError.localizedDescription)
    case .decodingError(let underlyingError):
        print("Decoding error:", underlyingError.localizedDescription)
    }
} catch {
    print("Unexpected error:", error)
}
```

## Configuration

```swift
let mk = MemoryKit(
    apiKey: "ctx_...",
    baseURL: URL(string: "https://api.memorykit.io/v1")!,
    timeout: 30,
    maxRetries: 3
)
```

> **Security**: Never embed API keys directly in your app binary. Use a backend proxy to keep keys secure.

## Links

- [Documentation](https://docs.memorykit.io)
- [API Reference](https://docs.memorykit.io/api)
- [Architecture](https://docs.memorykit.io/architecture)
- [Dashboard](https://platform.memorykit.io)

## License

MIT — see [LICENSE](LICENSE) for details.
