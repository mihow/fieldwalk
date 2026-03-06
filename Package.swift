// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FieldWalk",
    platforms: [.iOS(.v17)],
    dependencies: [
        .package(url: "https://github.com/vincentneo/CoreGPX.git", from: "0.9.0"),
    ],
    targets: [
        .executableTarget(
            name: "FieldWalk",
            dependencies: ["CoreGPX"],
            path: "Sources"
        ),
        .testTarget(
            name: "FieldWalkTests",
            dependencies: ["FieldWalk"],
            path: "Tests/FieldWalkTests"
        ),
    ]
)
