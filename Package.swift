// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

@_silgen_name("getenv")
func getenv(_ name: UnsafePointer<CChar>) -> UnsafePointer<CChar>?

func getEnv(_ name: String) -> String? {
    let cValue = name.withCString { ptr in
        getenv(ptr)
    }

    if cValue != nil {
        return String(cString: cValue!)
    } else {
        return nil
    }
}

struct SwingbyConf {
    var includePathFlags: [String]
    var libraryPathFlags: [String]
    var runpathFlags: [String]
}

let swingbyConf = SwingbyConf(
    includePathFlags: getEnv("BLUSHER_SWINGBY_INCLUDE_PATH").map { value in
        ["-I\(value)"]
    } ?? [],
    libraryPathFlags: getEnv("BLUSHER_SWINGBY_LIBRARY_PATH").map { value in
        ["-L\(value)"]
    } ?? [],
    runpathFlags: getEnv("BLUSHER_ENABLE_SWINGBY_RUNPATH").map { value in
        if value == "ON" {
            [
                "-Xlinker",
                "-rpath=\(getEnv("BLUSHER_SWINGBY_LIBRARY_PATH")!)",
            ]
        } else {
            []
        }
    } ?? []
)


let package = Package(
    name: "blusher",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.

        .library(
            name: "Blusher",
            type: .dynamic,
            targets: ["Blusher"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/blusher-project/blusher-brc-plugin.git",
            branch: "main"
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .systemLibrary(
            name: "CSwingby",
            path: "Sources/CSwingby"
        ),
        .systemLibrary(
            name: "CFontconfig",
            path: "Sources/CFontconfig"
        ),
        .systemLibrary(
            name: "CPango",
            path: "Sources/CPango",
            pkgConfig: "pangoft2"
        ),
        .target(
            name: "Blusher",
            dependencies: [
                "CSwingby",
                "CFontconfig",
                "CPango",
                "BlusherResources",
            ],
            swiftSettings: [
                .unsafeFlags(["-enable-library-evolution"]),
                .unsafeFlags(swingbyConf.includePathFlags),
            ],
            linkerSettings: [
                .unsafeFlags(swingbyConf.libraryPathFlags),
                .unsafeFlags(swingbyConf.runpathFlags),
            ]
        ),
        .target(
            name: "BlusherResources",
            // path: "Resources/BlusherResources",
            path: "Resources",
            linkerSettings: [
                .unsafeFlags(["-L.blusher/lib", "-lResources"]),
            ],
            plugins: [
                .plugin(name: "BlusherBRCPlugin", package: "blusher-brc-plugin"),
            ]
        ),
        .testTarget(
            name: "blusherTests",
            dependencies: ["Blusher"]
        ),
    ]
)
