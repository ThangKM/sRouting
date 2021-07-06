// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "sRouting",
    
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .tvOS(.v14)
    ],
    
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "sRouting",
            targets: ["sRouting"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "ViewInspector", url: "https://github.com/nalexn/ViewInspector", from: .init(0, 8, 1))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "sRouting",
            dependencies: []),
        .testTarget(
            name: "sRoutingTests",
            dependencies: ["sRouting","ViewInspector"]),
    ]
)
