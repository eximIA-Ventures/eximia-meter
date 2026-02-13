// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "EximiaMeter",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "EximiaMeter",
            path: "EximiaMeter",
            exclude: ["Resources"]
        ),
        .testTarget(
            name: "EximiaMeterTests",
            dependencies: ["EximiaMeter"],
            path: "EximiaMeterTests"
        )
    ]
)
