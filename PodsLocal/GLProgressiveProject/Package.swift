//swift-tools-version: 5.6
import PackageDescription

let package = Package(
    name: "GLProgressiveProject",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "GLProgressiveProject", targets: ["GLProgressiveProject"])
    ],
    targets: [
        .target(name: "GLProgressiveProject", dependencies: [], path: "Sources")
    ]
)
