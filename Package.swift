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
        .package(url: "https://github.com/PostHog/posthog-ios.git", from: "3.0.0"),
        .package(url: "https://github.com/supabase/supabase-swift.git", from: "2.0.0")
    ],
    targets: [
        .executableTarget(
            name: "multipaste",
            dependencies: [
                .product(name: "SQLite", package: "SQLite.swift"),
                .product(name: "PostHog", package: "posthog-ios"),
                .product(name: "Supabase", package: "supabase-swift")
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ]
        ),
        .executableTarget(
            name: "contextbrain"
        ),
    ]
)
