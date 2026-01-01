// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Scribe",
    platforms: [
        .macOS(.v14)  // macOS 14 Sonoma for latest SwiftUI features
    ],
    products: [
        .executable(name: "Scribe", targets: ["Scribe"])
    ],
    dependencies: [
        // Markdown parsing
        .package(url: "https://github.com/apple/swift-markdown.git", branch: "main"),
        // SQLite wrapper
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.24.0"),
        // Keyboard shortcuts
        .package(url: "https://github.com/sindresorhus/KeyboardShortcuts.git", from: "1.16.0"),
    ],
    targets: [
        .executableTarget(
            name: "Scribe",
            dependencies: [
                .product(name: "Markdown", package: "swift-markdown"),
                .product(name: "GRDB", package: "GRDB.swift"),
                .product(name: "KeyboardShortcuts", package: "KeyboardShortcuts"),
            ],
            path: "Sources/Scribe",
            resources: [
                .copy("Resources/lexical"),
                .copy("Resources/codemirror")
            ]
        ),
        .testTarget(
            name: "ScribeTests",
            dependencies: ["Scribe"],
            path: "Tests/ScribeTests"
        ),
    ]
)
