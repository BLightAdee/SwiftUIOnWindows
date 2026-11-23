// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SwiftListak",
    platforms: [
        .macOS(.v14) // macOS Sonoma/Sequoia or newer
    ],
    products: [
        .library(
            name: "SwiftListak",
            targets: ["SwiftListak"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SwiftListak",
            dependencies: [],
            path: "Sources/SwiftListak")
    ]
)
