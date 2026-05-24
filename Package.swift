// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "multipaste",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.14.1"),
        .package(url: "https://github.com/TelemetryDeck/SwiftSDK", from: "2.0.0")
    ],
    targets: [
        .executableTarget(
            name: "multipaste",
            dependencies: [
                .product(name: "SQLite", package: "SQLite.swift"),
                .product(name: "TelemetryDeck", package: "SwiftSDK")
            ]
        ),
        .executableTarget(
            name: "contextbrain"
        ),
    ]
)
