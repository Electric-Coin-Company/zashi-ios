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
        .library(name: "AudioServicesClient", targets: ["AudioServicesClient"]),
        .library(name: "CaptureDeviceClient", targets: ["CaptureDeviceClient"]),
        .library(name: "DatabaseFilesClient", targets: ["DatabaseFilesClient"]),
        .library(name: "DateClient", targets: ["DateClient"]),
        .library(name: "DeeplinkClient", targets: ["DeeplinkClient"]),
        .library(name: "DerivationToolClient", targets: ["DerivationToolClient"]),
        .library(name: "FileManager", targets: ["FileManager"]),
        .library(name: "Utils", targets: ["Utils"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.50.3"),
        .package(url: "https://github.com/pointfreeco/swift-url-routing", from: "0.5.0"),
        .package(url: "https://github.com/zcash/ZcashLightClientKit", revision: "ee3d082155bf542aa3580c84e6140a329633319a")
    ],
    targets: [
        .target(
            name: "AppVersionClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "AudioServicesClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "CaptureDeviceClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "DatabaseFilesClient",
            dependencies: [
                "FileManager",
                "Utils",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ZcashLightClientKit", package: "ZcashLightClientKit")
            ]
        ),
        .target(
            name: "DateClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "DeeplinkClient",
            dependencies: [
                "DerivationToolClient",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "URLRouting", package: "swift-url-routing"),
                .product(name: "ZcashLightClientKit", package: "ZcashLightClientKit")
            ]
        ),
        .target(
            name: "DerivationToolClient",
            dependencies: [
                "Utils",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ZcashLightClientKit", package: "ZcashLightClientKit")
            ]
        ),
        .target(
            name: "FileManager",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(name: "Utils")
    ]
)
