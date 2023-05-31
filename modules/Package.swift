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
        .library(name: "DiskSpaceCheckerClient", targets: ["DiskSpaceCheckerClient"]),
        .library(name: "FeedbackGeneratorClient", targets: ["FeedbackGeneratorClient"]),
        .library(name: "FileManager", targets: ["FileManager"]),
        .library(name: "Generated", targets: ["Generated"]),
        .library(name: "LocalAuthenticationClient", targets: ["LocalAuthenticationClient"]),
        .library(name: "LogsHandlerClient", targets: ["LogsHandlerClient"]),
        .library(name: "MnemonicClient", targets: ["MnemonicClient"]),
        .library(name: "Models", targets: ["Models"]),
        .library(name: "NumberFormatterClient", targets: ["NumberFormatterClient"]),
        .library(name: "PasteboardClient", targets: ["PasteboardClient"]),
        .library(name: "RecoveryPhraseValidationFlow", targets: ["RecoveryPhraseValidationFlow"]),
        .library(name: "ReviewRequestClient", targets: ["ReviewRequestClient"]),
        .library(name: "SDKSynchronizerClient", targets: ["SDKSynchronizerClient"]),
        .library(name: "SecItem", targets: ["SecItem"]),
        .library(name: "SupportDataGeneratorClient", targets: ["SupportDataGeneratorClient"]),
        .library(name: "UIComponents", targets: ["UIComponents"]),
        .library(name: "Utils", targets: ["Utils"]),
        .library(name: "UserDefaultsClient", targets: ["UserDefaultsClient"]),
        .library(name: "ZcashSDKEnvironment", targets: ["ZcashSDKEnvironment"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.50.3"),
        .package(url: "https://github.com/pointfreeco/swift-url-routing", from: "0.5.0"),
        .package(url: "https://github.com/zcash/ZcashLightClientKit", revision: "ee3d082155bf542aa3580c84e6140a329633319a"),
        .package(url: "https://github.com/zcash-hackworks/MnemonicSwift", from: "2.0.0")
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
            name: "DiskSpaceCheckerClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "FeedbackGeneratorClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "FileManager",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "Generated",
            resources: [.process("Resources")]
        ),
        .target(
            name: "LocalAuthenticationClient",
            dependencies: [
                "Generated",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "LogsHandlerClient",
            dependencies: [
                "Utils",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "MnemonicClient",
            dependencies: [
                .product(name: "MnemonicSwift", package: "MnemonicSwift"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "Models",
            dependencies: [
                "Utils",
                "UIComponents"
            ]
        ),
        .target(
            name: "NumberFormatterClient",
            dependencies: [
                "Utils",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "PasteboardClient",
            dependencies: [
                "Utils",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "RecoveryPhraseValidationFlow",
            dependencies: [
                "FeedbackGeneratorClient",
                "Generated",
                "Models",
                "PasteboardClient",
                "UIComponents",
                "Utils",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ZcashLightClientKit", package: "ZcashLightClientKit")
            ]
        ),
        .target(
            name: "ReviewRequestClient",
            dependencies: [
                "AppVersionClient",
                "DateClient",
                "UserDefaultsClient",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "SDKSynchronizerClient",
            dependencies: [
                "DatabaseFilesClient",
                "Models",
                "ZcashSDKEnvironment",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ZcashLightClientKit", package: "ZcashLightClientKit")
            ]
        ),
        .target(
            name: "SecItem",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "SupportDataGeneratorClient",
            dependencies: [
                "Generated",
                "Utils",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "UIComponents",
            dependencies: [
                "Generated",
                "Utils"
            ]
        ),
        .target(
            name: "Utils",
            dependencies: [
                .product(name: "ZcashLightClientKit", package: "ZcashLightClientKit")
            ]
        ),
        .target(
            name: "UserDefaultsClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "ZcashSDKEnvironment",
            dependencies: [
                .product(name: "ZcashLightClientKit", package: "ZcashLightClientKit"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        )
    ]
)
