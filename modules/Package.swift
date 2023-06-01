// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "modules",
    platforms: [
      .iOS(.v15)
    ],
    products: [
        .library(name: "AddressDetails", targets: ["AddressDetails"]),
        .library(name: "AppVersion", targets: ["AppVersion"]),
        .library(name: "AudioServices", targets: ["AudioServices"]),
        .library(name: "CaptureDevice", targets: ["CaptureDevice"]),
        .library(name: "DatabaseFiles", targets: ["DatabaseFiles"]),
        .library(name: "Date", targets: ["Date"]),
        .library(name: "Deeplink", targets: ["Deeplink"]),
        .library(name: "DerivationTool", targets: ["DerivationTool"]),
        .library(name: "DiskSpaceChecker", targets: ["DiskSpaceChecker"]),
        .library(name: "FeedbackGenerator", targets: ["FeedbackGenerator"]),
        .library(name: "FileManager", targets: ["FileManager"]),
        .library(name: "Generated", targets: ["Generated"]),
        .library(name: "LocalAuthenticationHandler", targets: ["LocalAuthenticationHandler"]),
        .library(name: "LogsHandler", targets: ["LogsHandler"]),
        .library(name: "MnemonicClient", targets: ["MnemonicClient"]),
        .library(name: "Models", targets: ["Models"]),
        .library(name: "NumberFormatter", targets: ["NumberFormatter"]),
        .library(name: "Pasteboard", targets: ["Pasteboard"]),
        .library(name: "Profile", targets: ["Profile"]),
        .library(name: "RecoveryPhraseDisplay", targets: ["RecoveryPhraseDisplay"]),
        .library(name: "RecoveryPhraseValidationFlow", targets: ["RecoveryPhraseValidationFlow"]),
        .library(name: "ReviewRequest", targets: ["ReviewRequest"]),
        .library(name: "SDKSynchronizer", targets: ["SDKSynchronizer"]),
        .library(name: "SecItem", targets: ["SecItem"]),
        .library(name: "SupportDataGenerator", targets: ["SupportDataGenerator"]),
        .library(name: "UIComponents", targets: ["UIComponents"]),
        .library(name: "URIParser", targets: ["URIParser"]),
        .library(name: "UserDefaults", targets: ["UserDefaults"]),
        .library(name: "UserPreferencesStorage", targets: ["UserPreferencesStorage"]),
        .library(name: "Utils", targets: ["Utils"]),
        .library(name: "WalletConfigProvider", targets: ["WalletConfigProvider"]),
        .library(name: "WalletStorage", targets: ["WalletStorage"]),
        .library(name: "Welcome", targets: ["Welcome"]),
        .library(name: "ZcashSDKEnvironment", targets: ["ZcashSDKEnvironment"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.50.3"),
        .package(url: "https://github.com/pointfreeco/swift-case-paths", from: "0.14.1"),
        .package(url: "https://github.com/pointfreeco/swift-url-routing", from: "0.5.0"),
        .package(url: "https://github.com/zcash/ZcashLightClientKit", revision: "ee3d082155bf542aa3580c84e6140a329633319a"),
        .package(url: "https://github.com/zcash-hackworks/MnemonicSwift", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "AddressDetails",
            dependencies: [
                "Generated",
                "Pasteboard",
                "UIComponents",
                "Utils",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ZcashLightClientKit", package: "ZcashLightClientKit")
            ],
            path: "Sources/Features/AddressDetails"
        ),
        .target(
            name: "AppVersion",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Sources/Dependencies/AppVersion"
        ),
        .target(
            name: "AudioServices",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Sources/Dependencies/AudioServices"
        ),
        .target(
            name: "CaptureDevice",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Sources/Dependencies/CaptureDevice"
        ),
        .target(
            name: "DatabaseFiles",
            dependencies: [
                "FileManager",
                "Utils",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ZcashLightClientKit", package: "ZcashLightClientKit")
            ],
            path: "Sources/Dependencies/DatabaseFiles"
        ),
        .target(
            name: "Date",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Sources/Dependencies/Date"
        ),
        .target(
            name: "Deeplink",
            dependencies: [
                "DerivationTool",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "URLRouting", package: "swift-url-routing"),
                .product(name: "ZcashLightClientKit", package: "ZcashLightClientKit")
            ],
            path: "Sources/Dependencies/Deeplink"
        ),
        .target(
            name: "DerivationTool",
            dependencies: [
                "Utils",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ZcashLightClientKit", package: "ZcashLightClientKit")
            ],
            path: "Sources/Dependencies/DerivationTool"
        ),
        .target(
            name: "DiskSpaceChecker",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ],
            path: "Sources/Dependencies/DiskSpaceChecker"
        ),
        .target(
            name: "FeedbackGenerator",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Sources/Dependencies/FeedbackGenerator"
        ),
        .target(
            name: "FileManager",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Sources/Dependencies/FileManager"
        ),
        .target(
            name: "Generated",
            resources: [.process("Resources")]
        ),
        .target(
            name: "LocalAuthenticationHandler",
            dependencies: [
                "Generated",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Sources/Dependencies/LocalAuthenticationHandler"
        ),
        .target(
            name: "LogsHandler",
            dependencies: [
                "Utils",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Sources/Dependencies/LogsHandler"
        ),
        .target(
            name: "MnemonicClient",
            dependencies: [
                .product(name: "MnemonicSwift", package: "MnemonicSwift"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Sources/Dependencies/MnemonicClient"
        ),
        .target(
            name: "Models",
            dependencies: [
                "Utils",
                "UIComponents"
            ],
            path: "Sources/Models"
        ),
        .target(
            name: "NumberFormatter",
            dependencies: [
                "Utils",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Sources/Dependencies/NumberFormatter"
        ),
        .target(
            name: "Pasteboard",
            dependencies: [
                "Utils",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Sources/Dependencies/Pasteboard"
        ),
        .target(
            name: "Profile",
            dependencies: [
                "AddressDetails",
                "AppVersion",
                "Generated",
                "SDKSynchronizer",
                "UIComponents",
                "Utils",
                "ZcashSDKEnvironment",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ZcashLightClientKit", package: "ZcashLightClientKit")
            ],
            path: "Sources/Features/Profile"
        ),
        .target(
            name: "RecoveryPhraseDisplay",
            dependencies: [
                "Generated",
                "Models",
                "Pasteboard",
                "UIComponents",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Sources/Features/RecoveryPhraseDisplay"
        ),
        .target(
            name: "RecoveryPhraseValidationFlow",
            dependencies: [
                "FeedbackGenerator",
                "Generated",
                "Models",
                "Pasteboard",
                "UIComponents",
                "Utils",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ZcashLightClientKit", package: "ZcashLightClientKit")
            ],
            path: "Sources/Features/RecoveryPhraseValidationFlow"
        ),
        .target(
            name: "ReviewRequest",
            dependencies: [
                "AppVersion",
                "Date",
                "UserDefaults",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Sources/Dependencies/ReviewRequest"
        ),
        .target(
            name: "SDKSynchronizer",
            dependencies: [
                "DatabaseFiles",
                "Models",
                "ZcashSDKEnvironment",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ZcashLightClientKit", package: "ZcashLightClientKit")
            ],
            path: "Sources/Dependencies/SDKSynchronizer"
        ),
        .target(
            name: "SecItem",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Sources/Dependencies/SecItem"
        ),
        .target(
            name: "SupportDataGenerator",
            dependencies: [
                "Generated",
                "Utils",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Sources/Dependencies/SupportDataGenerator"
        ),
        .target(
            name: "UIComponents",
            dependencies: [
                "Generated",
                "Utils"
            ],
            path: "Sources/UIComponents"
        ),
        .target(
            name: "URIParser",
            dependencies: [
                "DerivationTool",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ZcashLightClientKit", package: "ZcashLightClientKit")
            ],
            path: "Sources/Dependencies/URIParser"
        ),
        .target(
            name: "UserDefaults",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Sources/Dependencies/UserDefaults"
        ),
        .target(
            name: "UserPreferencesStorage",
            dependencies: [
                "UserDefaults",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Sources/Dependencies/UserPreferencesStorage"
        ),
        .target(
            name: "Utils",
            dependencies: [
                .product(name: "ZcashLightClientKit", package: "ZcashLightClientKit"),
                .product(name: "CasePaths", package: "swift-case-paths")
            ],
            path: "Sources/Utils"
        ),
        .target(
            name: "WalletConfigProvider",
            dependencies: [
                "Utils",
                "Models",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Sources/Dependencies/WalletConfigProvider"
        ),
        .target(
            name: "WalletStorage",
            dependencies: [
                "Utils",
                "SecItem",
                "MnemonicClient",
                "Models",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ZcashLightClientKit", package: "ZcashLightClientKit")
            ],
            path: "Sources/Dependencies/WalletStorage"
        ),
        .target(
            name: "Welcome",
            dependencies: [
                "Generated",
                "UIComponents",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Sources/Features/Welcome"
        ),
        .target(
            name: "ZcashSDKEnvironment",
            dependencies: [
                .product(name: "ZcashLightClientKit", package: "ZcashLightClientKit"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Sources/Dependencies/ZcashSDKEnvironment"
        )
    ]
)
