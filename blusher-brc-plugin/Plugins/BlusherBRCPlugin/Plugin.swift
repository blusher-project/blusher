import PackagePlugin
import Foundation
import Glibc

@main
struct BlusherBRCPlugin: BuildToolPlugin {
    func createBuildCommands(
        context: PluginContext,
        target: Target
    ) throws -> [Command] {
        // Find `blusher` command or using internal one.
        var cmd = URL(fileURLWithPath: "/usr/bin/blusher")
        if access(cmd.path, X_OK) != 0 {
            cmd = URL(fileURLWithPath: "/usr/local/bin/blusher")
        }
        if access(cmd.path, X_OK) != 0 {
            // TODO: This will never works.
            cmd = URL(fileURLWithPath: "~/.blusher/bin/blusher")
        }

        let projectRoot = context.package.directoryURL
        let inputDir = target.directoryURL
        let outputDir = context.pluginWorkDirectoryURL

        // Get .brc files.
        guard let _files = try? FileManager.default.contentsOfDirectory(
            at: inputDir,
            includingPropertiesForKeys: nil
        ) else {
            return []
        }
        let brcFiles = _files.filter { $0.pathExtension == "brc" }

        // Create directories.
        try FileManager.default.createDirectory(
            atPath: outputDir.appendingPathComponent("brc").path,
            withIntermediateDirectories: true
        )
        try FileManager.default.createDirectory(
            atPath: projectRoot.appendingPathComponent(".blusher/lib").path,
            withIntermediateDirectories: true
        )
        try FileManager.default.createDirectory(
            atPath: outputDir.appendingPathComponent("src").path,
            withIntermediateDirectories: true
        )

        // TODO: describe why.
        let noblusherFlags = context.package.displayName == "blusher"
            ? ["--noblusher"]
            : []

        // Make commands.
        let libCommands: [Command] = brcFiles.map { url in
            let libPath = "lib\(url.deletingPathExtension().lastPathComponent).a"
            // TODO: Remove?
            let outputURL = outputDir
                .appendingPathComponent("lib")
                .appendingPathComponent(libPath)

            Diagnostics.warning(" inputDir: \(inputDir)")
            let aDir = projectRoot.appendingPathComponent(".blusher/lib")

            return .buildCommand(
                displayName: "Blusher Resource Compiler Plugin - \(url)",
                executable: cmd,
                arguments: [
                    "rcc",
                    "\(inputDir.path)/\(url.lastPathComponent)",
                    "-C", "\(outputDir.path)/brc",
                    "-o", "\(aDir.path)/\(libPath)",
                ],
                inputFiles: [url],
                outputFiles: []
            )
        }
        let srcCommands: [Command] = brcFiles.map { url in
            let swiftPath = "\(url.deletingPathExtension().lastPathComponent).swift"
            let outputURL = outputDir
                .appendingPathComponent("src")
                .appendingPathComponent(swiftPath)

            return .buildCommand(
                displayName: "Blusher Resource Compiler Plugin - .swift",
                executable: cmd,
                arguments: [
                    "rc-gen",
                    "\(inputDir.path)/\(url.lastPathComponent)",
                    "-C", "\(outputDir.path)/src",
                ] + noblusherFlags,
                inputFiles: [url],
                outputFiles: [outputURL]
            )
        }

        return libCommands + srcCommands

        return [
            .prebuildCommand(
                displayName: "Blusher Resource Compiler Plugin - Compile",
                executable: cmd,
                arguments: [
                    "rcc",
                    "\(inputDir.path)/resources.brc",
                    "-C", "\(outputDir.path)/brc",
                    "-o", "\(outputDir.path)/brc/libresources.a",
                ],
                outputFilesDirectory: outputDir.appendingPathComponent("src")
            ),
            .prebuildCommand(
                displayName: "Blusher Resource Compiler Plugin - Generate Code",
                executable: cmd,
                arguments: [
                    "rc-gen",
                    "\(inputDir.path)/resources.brc",
                    "-C", "\(outputDir.path)/src",
                ],
                outputFilesDirectory: outputDir.appendingPathComponent("src")
            ),
        ]
    }
}
