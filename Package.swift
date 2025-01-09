// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "sRouting",
    
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .visionOS(.v1)
    ],
    
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "sRouting",
            targets: ["sRouting"]),
        .executable(
            name: "sRoutingClient",
            targets: ["sRoutingClient"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
        .package(url: "https://github.com/nalexn/ViewInspector", from: .init(0, 9, 9))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .macro(
            name: "sRoutingMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        
        // Library that exposes a macro as part of its API, which is used in client programs.
        .target(name: "sRouting",
                dependencies: ["sRoutingMacros"],
                resources: [.copy("PrivacyInfo.xcprivacy")]),
        
        // A client of the library, which is able to use the macro in its own code.
        .executableTarget(name: "sRoutingClient", dependencies: ["sRouting"]),
    
        .testTarget(
            name: "sRoutingTests",
            dependencies: ["sRouting","ViewInspector","sRoutingMacros",
                           .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),]),
    ]
)
