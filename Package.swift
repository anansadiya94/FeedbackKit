// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FeedbackKit",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "FeedbackKit", targets: ["FeedbackKitUI"]),
        .library(name: "FeedbackKitCore", targets: ["FeedbackKitCore"]),
        .library(name: "FeedbackKitJira", targets: ["FeedbackKitJira"]),
        .library(name: "FeedbackKitAI", targets: ["FeedbackKitAI"]),
        .library(name: "FeedbackKitUI", targets: ["FeedbackKitUI"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "1.18.0"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-dependencies",
            from: "1.8.0"
        ),
    ],
    targets: [
        .target(
            name: "FeedbackKitCore",
            dependencies: []
        ),
        .target(
            name: "FeedbackKitJira",
            dependencies: ["FeedbackKitCore"]
        ),
        .target(
            name: "FeedbackKitAI",
            dependencies: ["FeedbackKitCore"]
        ),
        .target(
            name: "FeedbackKitUI",
            dependencies: [
                "FeedbackKitCore",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Dependencies", package: "swift-dependencies"),
            ]
        ),
        .testTarget(
            name: "FeedbackKitCoreTests",
            dependencies: ["FeedbackKitCore"]
        ),
        .testTarget(
            name: "FeedbackKitJiraTests",
            dependencies: ["FeedbackKitJira"]
        ),
        .testTarget(
            name: "FeedbackKitAITests",
            dependencies: ["FeedbackKitAI"]
        ),
        .testTarget(
            name: "FeedbackKitUITests",
            dependencies: [
                "FeedbackKitUI",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
    ]
)
