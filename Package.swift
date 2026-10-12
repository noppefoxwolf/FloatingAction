// swift-tools-version: 6.4
import PackageDescription

let package = Package(
    name: "FloatingAction",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "FloatingAction", targets: ["FloatingAction"])
    ],
    targets: [
        .target(name: "FloatingAction"),
        .testTarget(
            name: "FloatingActionTests",
            dependencies: ["FloatingAction"]
        )
    ]
)
