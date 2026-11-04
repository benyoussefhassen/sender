// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SenderProMac",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "SenderProMac", targets: ["SenderProMac"])
    ],
    targets: [
        .executableTarget(
            name: "SenderProMac",
            path: "Sources/SenderProMac",
            linkerSettings: [
                .linkedLibrary("sqlite3"),
                .linkedFramework("AppKit"),
                .linkedFramework("SwiftUI"),
                .linkedFramework("WebKit"),
                .linkedFramework("Network"),
                .linkedFramework("Security"),
                .linkedFramework("AVFoundation")
            ]
        ),
        .testTarget(
            name: "SenderProMacTests",
            dependencies: ["SenderProMac"],
            path: "Tests/SenderProMacTests"
        )
    ]
)
