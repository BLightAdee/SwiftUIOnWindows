// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SwiftUIOnWindows",
    products: [
        .library(
            name: "SwiftUIOnWindows",
            targets: ["SwiftUIOnWindows"]
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
        .executableTarget(
            name: "SwiftUIDemo",
            dependencies: ["SwiftUIOnWindows"],
            path: "Sources/SwiftUIDemo"
        )
    ]
)
