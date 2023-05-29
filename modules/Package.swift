// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "modules",
    platforms: [
      .iOS(.v15),
    ],
    products: [
        .library(name: "AppVersionClient", targets: ["AppVersionClient"]),
        .library(name: "DateClient", targets: ["DateClient"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.50.3")
    ],
    targets: [
        .target(
            name: "AppVersionClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "DateClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        )
    ]
)
