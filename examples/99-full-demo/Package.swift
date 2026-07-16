// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "example",
    dependencies: [
    ],
    targets: [
        .executableTarget(
            name: "Example",
            dependencies: [],
            swiftSettings: [
                .unsafeFlags(["-I../../.build/debug/Modules"]),
                .unsafeFlags(["-I../../.build/release/Modules"]),
            ],
            linkerSettings: [
                .linkedLibrary("Blusher"),
                .unsafeFlags(["-L../../.build/debug"]),
                .unsafeFlags(["-L../../.build/release"]),
            ]
        ),
    ]
)
