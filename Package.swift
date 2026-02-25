// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "MemoryKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "MemoryKit",
            targets: ["MemoryKit"]
        )
    ],
    targets: [
        .target(
            name: "MemoryKit",
            path: "Sources/MemoryKit"
        ),
        .testTarget(
            name: "MemoryKitTests",
            dependencies: ["MemoryKit"],
            path: "Tests/MemoryKitTests"
        )
    ]
)
