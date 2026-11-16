// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let tmpV6_4 = "\(Context.packageDirectory)/../../.build/out/Intermediates.noindex/"
    + "blusher.build/Debug-linux-x86_64/Blusher-t.build/Objects-normal/x86_64"

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
                .unsafeFlags(["-I\(tmpV6_4)"]),
            ],
            linkerSettings: [
                .linkedLibrary("Blusher"),
                .unsafeFlags(["-L../../.build/debug"]),
                .unsafeFlags(["-L../../.build/release"]),
            ]
        ),
    ]
)
