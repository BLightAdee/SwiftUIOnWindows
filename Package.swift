// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SwiftUIOnWindows",
    products: [
        .library(
            name: "SwiftUIOnWindows",
            targets: ["SwiftUIOnWindows"]
        ),
        .library(
            name: "SwiftUI",
            targets: ["SwiftUI"]
        ),
        .executable(
            name: "SwiftUIDemo",
            targets: ["SwiftUIDemo"]
        )
    ],
    targets: [
        .target(
            name: "SwiftUIOnWindows",
            dependencies: [],
            path: "Sources/SwiftUIOnWindows",
            swiftSettings: [
                .define("SWIFTUIONWINDOWS")
            ]
        ),
        .target(
            name: "SwiftUI",
            dependencies: ["SwiftUIOnWindows"],
            path: "Sources/SwiftUI"
        ),
        .executableTarget(
            name: "SwiftUIDemo",
            dependencies: ["SwiftUIOnWindows"],
            path: "Sources/SwiftUIDemo"
        )
    ]
)
