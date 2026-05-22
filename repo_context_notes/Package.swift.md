---
file: Package.swift
size: 827
mtime: 2026-05-21T11:52:34.533675Z
sha256: ae0f4c63c5ffff33d3371d9f81b622180c533fc5ab3611eca60750ff03c3fb3b
---

# Package.swift

**Summary:** // swift-tools-version: 5.9

## Preview

```
// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "multipaste",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.14.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "multipaste",
            dependencies: [
                .product(name: "SQLite", package: "SQLite.swift")
            ]
        ),
        .executableTarget(
            name: "contextbrain"
        ),
    ]
)
```
