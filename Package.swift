// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "ExchageAgregator",
    products: [
        .library(name: "ExchageAgregator", targets: ["App"]),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),

        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0"),
        .package(url: "https://github.com/Hearst-DD/ObjectMapper.git", from: "3.4.2"),
        .package(url: "https://github.com/vapor/websocket.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.2")
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentSQLite", "Vapor", "ObjectMapper", "WebSocket", "Leaf"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

