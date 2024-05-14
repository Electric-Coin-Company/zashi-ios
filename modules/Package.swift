// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "modules",
    platforms: [
      .iOS(.v15)
    ],
    products: [
        .library(name: "About", targets: ["About"]),
        .library(name: "AddressDetails", targets: ["AddressDetails"]),
        .library(name: "AppVersion", targets: ["AppVersion"]),
        .library(name: "AudioServices", targets: ["AudioServices"]),
        .library(name: "BalanceBreakdown", targets: ["BalanceBreakdown"]),
        .library(name: "BalanceFormatter", targets: ["BalanceFormatter"]),
        .library(name: "CaptureDevice", targets: ["CaptureDevice"]),
        .library(name: "CrashReporter", targets: ["CrashReporter"]),
        .library(name: "DatabaseFiles", targets: ["DatabaseFiles"]),
        .library(name: "Date", targets: ["Date"]),
        .library(name: "Deeplink", targets: ["Deeplink"]),
        .library(name: "DeleteWallet", targets: ["DeleteWallet"]),
        .library(name: "DerivationTool", targets: ["DerivationTool"]),
        .library(name: "DiskSpaceChecker", targets: ["DiskSpaceChecker"]),
        .library(name: "ExportLogs", targets: ["ExportLogs"]),
        .library(name: "FeedbackGenerator", targets: ["FeedbackGenerator"]),
        .library(name: "FileManager", targets: ["FileManager"]),
        .library(name: "Generated", targets: ["Generated"]),
        .library(name: "HideBalances", targets: ["HideBalances"]),
        .library(name: "Home", targets: ["Home"]),
        .library(name: "ImportWallet", targets: ["ImportWallet"]),
        .library(name: "LocalAuthenticationHandler", targets: ["LocalAuthenticationHandler"]),
        .library(name: "LogsHandler", targets: ["LogsHandler"]),
        .library(name: "MnemonicClient", targets: ["MnemonicClient"]),
        .library(name: "Models", targets: ["Models"]),
        .library(name: "NotEnoughFreeSpace", targets: ["NotEnoughFreeSpace"]),
        .library(name: "NumberFormatter", targets: ["NumberFormatter"]),
        .library(name: "OnboardingFlow", targets: ["OnboardingFlow"]),
        .library(name: "PartialProposalError", targets: ["PartialProposalError"]),
        .library(name: "Pasteboard", targets: ["Pasteboard"]),
        .library(name: "PrivateDataConsent", targets: ["PrivateDataConsent"]),
        .library(name: "QRImageDetector", targets: ["QRImageDetector"]),
        .library(name: "RecoveryPhraseDisplay", targets: ["RecoveryPhraseDisplay"]),
        .library(name: "ReviewRequest", targets: ["ReviewRequest"]),
        .library(name: "Root", targets: ["Root"]),
        .library(name: "Sandbox", targets: ["Sandbox"]),
        .library(name: "Scan", targets: ["Scan"]),
        .library(name: "SDKSynchronizer", targets: ["SDKSynchronizer"]),
        .library(name: "SecItem", targets: ["SecItem"]),
        .library(name: "SecurityWarning", targets: ["SecurityWarning"]),
        .library(name: "SendConfirmation", targets: ["SendConfirmation"]),
        .library(name: "SendFlow", targets: ["SendFlow"]),
        .library(name: "ServerSetup", targets: ["ServerSetup"]),
        .library(name: "Settings", targets: ["Settings"]),
        .library(name: "SupportDataGenerator", targets: ["SupportDataGenerator"]),
        .library(name: "SyncProgress", targets: ["SyncProgress"]),
        .library(name: "ReadTransactionsStorage", targets: ["ReadTransactionsStorage"]),
        .library(name: "RestoreWalletStorage", targets: ["RestoreWalletStorage"]),
        .library(name: "Tabs", targets: ["Tabs"]),
        .library(name: "TransactionList", targets: ["TransactionList"]),
        .library(name: "UIComponents", targets: ["UIComponents"]),
        .library(name: "URIParser", targets: ["URIParser"]),
        .library(name: "UserDefaults", targets: ["UserDefaults"]),
        .library(name: "UserPreferencesStorage", targets: ["UserPreferencesStorage"]),
        .library(name: "Utils", targets: ["Utils"]),
        .library(name: "WalletBalances", targets: ["WalletBalances"]),
        .library(name: "WalletConfigProvider", targets: ["WalletConfigProvider"]),
        .library(name: "WalletStorage", targets: ["WalletStorage"]),
        .library(name: "Welcome", targets: ["Welcome"]),
        .library(name: "WhatsNew", targets: ["WhatsNew"]),
        .library(name: "WhatsNewProvider", targets: ["WhatsNewProvider"]),
        .library(name: "ZcashSDKEnvironment", targets: ["ZcashSDKEnvironment"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-custom-dump.git", from: "1.3.0"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.9.2"),
        .package(url: "https://github.com/pointfreeco/swift-case-paths", from: "1.3.2"),
        .package(url: "https://github.com/pointfreeco/swift-url-routing", from: "0.6.0"),
        .package(url: "https://github.com/zcash-hackworks/MnemonicSwift", from: "2.2.4"),
        .package(url: "https://github.com/Electric-Coin-Company/zcash-swift-wallet-sdk", from: "2.1.5"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.24.0")
    ],
    targets: [
        .target(
            name: "About",
            dependencies: [
                "AppVersion",
                "Generated",
                "RestoreWalletStorage",
                "UIComponents",
                "WhatsNew",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ],
            path: "Sources/Features/About"
        ),
        .target(
            name: "AddressDetails",
            dependencies: [
                "Generated",
                "Pasteboard",
                "UIComponents",
                "Utils",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ZcashLightClientKit", package: "zcash-swift-wallet-sdk")
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
            name: "BalanceBreakdown",
            dependencies: [
                "BalanceFormatter",
                "Generated",
                "DerivationTool",
                "MnemonicClient",
                "Models",
                "NumberFormatter",
                "PartialProposalError",
                "RestoreWalletStorage",
                "SDKSynchronizer",
                "SyncProgress",
                "UIComponents",
                "Utils",
                "WalletBalances",
                "WalletStorage",
                "ZcashSDKEnvironment",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ZcashLightClientKit", package: "zcash-swift-wallet-sdk")
            ],
            path: "Sources/Features/BalanceBreakdown"
        ),
        .target(
            name: "BalanceFormatter",
            dependencies: [
                "Generated",
                "Utils",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ZcashLightClientKit", package: "zcash-swift-wallet-sdk")
            ],
            path: "Sources/Dependencies/BalanceFormatter"
        ),
        .target(
            name: "CaptureDevice",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Sources/Dependencies/CaptureDevice"
        ),
        .target(
            name: "CrashReporter",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk")
            ],
            path: "Sources/Dependencies/CrashReporter"
        ),
        .target(
            name: "DatabaseFiles",
            dependencies: [
                "FileManager",
                "Utils",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ZcashLightClientKit", package: "zcash-swift-wallet-sdk")
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
                .product(name: "ZcashLightClientKit", package: "zcash-swift-wallet-sdk")
            ],
            path: "Sources/Dependencies/Deeplink"
        ),
        .target(
            name: "DeleteWallet",
            dependencies: [
                "Generated",
                "SDKSynchronizer",
                "UIComponents",
                "Utils",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ZcashLightClientKit", package: "zcash-swift-wallet-sdk")
            ],
            path: "Sources/Features/DeleteWallet"
        ),
        .target(
            name: "DerivationTool",
            dependencies: [
                "Utils",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ZcashLightClientKit", package: "zcash-swift-wallet-sdk")
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
            name: "ExportLogs",
            dependencies: [
                "Generated",
                "LogsHandler",
                "Utils",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ZcashLightClientKit", package: "zcash-swift-wallet-sdk")
            ],
            path: "Sources/Features/ExportLogs"
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
            name: "HideBalances",
            dependencies: [
                "UserDefaults",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Sources/Dependencies/HideBalances"
        ),
        .target(
            name: "Home",
            dependencies: [
                "Generated",
                "Models",
                "RestoreWalletStorage",
                "ReviewRequest",
                "Scan",
                "Settings",
                "SDKSynchronizer",
                "SyncProgress",
                "UIComponents",
                "Utils",
                "TransactionList",
                "WalletBalances",
                "ZcashSDKEnvironment",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ZcashLightClientKit", package: "zcash-swift-wallet-sdk")
            ],
            path: "Sources/Features/Home"
        ),
        .target(
            name: "ImportWallet",
            dependencies: [
                "Generated",
                "MnemonicClient",
                "UIComponents",
                "Utils",
                "WalletStorage",
                "ZcashSDKEnvironment",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ZcashLightClientKit", package: "zcash-swift-wallet-sdk")
            ],
            path: "Sources/Features/ImportWallet"
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
                "UIComponents",
                .product(name: "MnemonicSwift", package: "MnemonicSwift")
            ],
            path: "Sources/Models"
        ),
        .target(
            name: "NotEnoughFreeSpace",
            dependencies: [
                "DiskSpaceChecker",
                "Generated",
                "Settings",
                "UIComponents",
                "Utils",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Sources/Features/NotEnoughFreeSpace"
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
            name: "OnboardingFlow",
            dependencies: [
                "Generated",
                "ImportWallet",
                "Models",
                "SecurityWarning",
                "UIComponents",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ZcashLightClientKit", package: "zcash-swift-wallet-sdk")
            ],
            path: "Sources/Features/OnboardingFlow"
        ),
        .target(
            name: "PartialProposalError",
            dependencies: [
                "Generated",
                "SupportDataGenerator",
                "UIComponents",
                "Utils",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Sources/Features/PartialProposalError"
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
            name: "PrivateDataConsent",
            dependencies: [
                "ExportLogs",
                "DatabaseFiles",
                "Generated",
                "Models",
                "RestoreWalletStorage",
                "UIComponents",
                "Utils",
                "ZcashSDKEnvironment",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Sources/Features/PrivateDataConsent"
        ),
        .target(
            name: "QRImageDetector",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Sources/Dependencies/QRImageDetector"
        ),
        .target(
            name: "RecoveryPhraseDisplay",
            dependencies: [
                "Generated",
                "MnemonicClient",
                "Models",
                "NumberFormatter",
                "UIComponents",
                "Utils",
                "WalletStorage",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ZcashLightClientKit", package: "zcash-swift-wallet-sdk")
            ],
            path: "Sources/Features/RecoveryPhraseDisplay"
        ),
        .target(
            name: "RestoreWalletStorage",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Sources/Dependencies/RestoreWalletStorage"
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
            name: "Root",
            dependencies: [
                "CrashReporter",
                "DatabaseFiles",
                "Deeplink",
                "DerivationTool",
                "DiskSpaceChecker",
                "ExportLogs",
                "Generated",
                "HideBalances",
                "MnemonicClient",
                "Models",
                "NotEnoughFreeSpace",
                "NumberFormatter",
                "OnboardingFlow",
                "Pasteboard",
                "ReadTransactionsStorage",
                "RecoveryPhraseDisplay",
                "RestoreWalletStorage",
                "Sandbox",
                "SDKSynchronizer",
                "Tabs",
                "UIComponents",
                "UserDefaults",
                "UserPreferencesStorage",
                "Utils",
                "WalletConfigProvider",
                "WalletStorage",
                "Welcome",
                "ZcashSDKEnvironment",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ZcashLightClientKit", package: "zcash-swift-wallet-sdk")
            ],
            path: "Sources/Features/Root"
        ),
        .target(
            name: "Sandbox",
            dependencies: [
                "RecoveryPhraseDisplay",
                "Scan",
                "SendFlow",
                "TransactionList",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ZcashLightClientKit", package: "zcash-swift-wallet-sdk")
            ],
            path: "Sources/Features/Sandbox"
        ),
        .target(
            name: "Scan",
            dependencies: [
                "CaptureDevice",
                "Generated",
                "QRImageDetector",
                "URIParser",
                "UIComponents",
                "Utils",
                "ZcashSDKEnvironment",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ZcashLightClientKit", package: "zcash-swift-wallet-sdk")
            ],
            path: "Sources/Features/Scan"
        ),
        .target(
            name: "SDKSynchronizer",
            dependencies: [
                "DatabaseFiles",
                "Models",
                "ZcashSDKEnvironment",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ZcashLightClientKit", package: "zcash-swift-wallet-sdk")
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
            name: "SecurityWarning",
            dependencies: [
                "AppVersion",
                "Generated",
                "MnemonicClient",
                "Models",
                "NumberFormatter",
                "RecoveryPhraseDisplay",
                "UIComponents",
                "Utils",
                "WalletStorage",
                "ZcashSDKEnvironment",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Sources/Features/SecurityWarning"
        ),
        .target(
            name: "SendConfirmation",
            dependencies: [
                "AudioServices",
                "BalanceFormatter",
                "DerivationTool",
                "Generated",
                "LocalAuthenticationHandler",
                "MnemonicClient",
                "Models",
                "PartialProposalError",
                "Scan",
                "SDKSynchronizer",
                "UIComponents",
                "Utils",
                "WalletBalances",
                "WalletStorage",
                "ZcashSDKEnvironment",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ZcashLightClientKit", package: "zcash-swift-wallet-sdk")
            ],
            path: "Sources/Features/SendConfirmation"
        ),
        .target(
            name: "SendFlow",
            dependencies: [
                "AudioServices",
                "BalanceFormatter",
                "DerivationTool",
                "Generated",
                "Models",
                "Scan",
                "SDKSynchronizer",
                "UIComponents",
                "Utils",
                "WalletBalances",
                "ZcashSDKEnvironment",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ZcashLightClientKit", package: "zcash-swift-wallet-sdk")
            ],
            path: "Sources/Features/SendFlow"
        ),
        .target(
            name: "ServerSetup",
            dependencies: [
                "Generated",
                "SDKSynchronizer",
                "UIComponents",
                "UserPreferencesStorage",
                "ZcashSDKEnvironment",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ZcashLightClientKit", package: "zcash-swift-wallet-sdk")
            ],
            path: "Sources/Features/ServerSetup"
        ),
        .target(
            name: "Settings",
            dependencies: [
                "About",
                "AppVersion",
                "DeleteWallet",
                "Generated",
                "LocalAuthenticationHandler",
                "Models",
                "Pasteboard",
                "PrivateDataConsent",
                "RecoveryPhraseDisplay",
                "RestoreWalletStorage",
                "ServerSetup",
                "SupportDataGenerator",
                "UIComponents",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ZcashLightClientKit", package: "zcash-swift-wallet-sdk")
            ],
            path: "Sources/Features/Settings"
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
            name: "SyncProgress",
            dependencies: [
                "Generated",
                "Models",
                "SDKSynchronizer",
                "UIComponents",
                "Utils",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Sources/Features/SyncProgress"
        ),
        .target(
            name: "ReadTransactionsStorage",
            dependencies: [
                "Utils",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Sources/Dependencies/ReadTransactionsStorage"
        ),
        .target(
            name: "Tabs",
            dependencies: [
                "AddressDetails",
                "BalanceBreakdown",
                "Generated",
                "HideBalances",
                "Home",
                "RestoreWalletStorage",
                "SendConfirmation",
                "SendFlow",
                "Settings",
                "UIComponents",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ZcashLightClientKit", package: "zcash-swift-wallet-sdk")
            ],
            path: "Sources/Features/Tabs"
        ),
        .target(
            name: "TransactionList",
            dependencies: [
                "Generated",
                "Models",
                "Pasteboard",
                "SDKSynchronizer",
                "ReadTransactionsStorage",
                "UIComponents",
                "Utils",
                "ZcashSDKEnvironment",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ZcashLightClientKit", package: "zcash-swift-wallet-sdk")
            ],
            path: "Sources/Features/TransactionList"
        ),
        .target(
            name: "UIComponents",
            dependencies: [
                "BalanceFormatter",
                "DerivationTool",
                "Generated",
                "HideBalances",
                "NumberFormatter",
                "SupportDataGenerator",
                "Utils",
                "ZcashSDKEnvironment"
            ],
            path: "Sources/UIComponents"
        ),
        .target(
            name: "URIParser",
            dependencies: [
                "DerivationTool",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ZcashLightClientKit", package: "zcash-swift-wallet-sdk")
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
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ZcashLightClientKit", package: "zcash-swift-wallet-sdk")
            ],
            path: "Sources/Dependencies/UserPreferencesStorage"
        ),
        .target(
            name: "Utils",
            dependencies: [
                .product(name: "ZcashLightClientKit", package: "zcash-swift-wallet-sdk"),
                .product(name: "CasePaths", package: "swift-case-paths"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Sources/Utils"
        ),
        .target(
            name: "WalletBalances",
            dependencies: [
                "Generated",
                "Models",
                "SDKSynchronizer",
                "UIComponents",
                "Utils",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ZcashLightClientKit", package: "zcash-swift-wallet-sdk")
            ],
            path: "Sources/Features/WalletBalances"
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
                .product(name: "ZcashLightClientKit", package: "zcash-swift-wallet-sdk")
            ],
            path: "Sources/Dependencies/WalletStorage"
        ),
        .target(
            name: "Welcome",
            dependencies: [
                "Generated",
                "NumberFormatter",
                "UIComponents",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Sources/Features/Welcome"
        ),
        .target(
            name: "WhatsNew",
            dependencies: [
                "Generated",
                "UIComponents",
                "WhatsNewProvider",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Sources/Features/WhatsNew"
        ),
        .target(
            name: "WhatsNewProvider",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Sources/Dependencies/WhatsNewProvider"
        ),
        .target(
            name: "ZcashSDKEnvironment",
            dependencies: [
                "Generated",
                "UserDefaults",
                "UserPreferencesStorage",
                .product(name: "ZcashLightClientKit", package: "zcash-swift-wallet-sdk"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Sources/Dependencies/ZcashSDKEnvironment"
        )
    ]
)
