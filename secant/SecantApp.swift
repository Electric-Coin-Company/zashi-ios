//
//  secantApp.swift
//  secant
//
//  Created by Francisco Gindre on 7/29/21.
//

import SwiftUI
import ComposableArchitecture
import Generated
import ZcashLightClientKit
import SDKSynchronizer
import Utils
import Root

final class AppDelegate: NSObject, UIApplicationDelegate {
    var rootStore = RootStore(
        initialState: .placeholder,
        reducer: RootReducer(
            tokenName: TargetConstants.tokenName,
            zcashNetwork: TargetConstants.zcashNetwork
        ).logging()
    )
    lazy var rootViewStore = ViewStore(
        rootStore.stateless,
        removeDuplicates: ==
    )

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        walletLogger = OSLogger(logLevel: .debug, category: LoggerConstants.walletLogs)
        // set the default behavior for the NSDecimalNumber
        NSDecimalNumber.defaultBehavior = Zatoshi.decimalHandler
        rootViewStore.send(.initialization(.appDelegate(.didFinishLaunching)))
        return true
    }

    func application(
        _ application: UIApplication,
        shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplication.ExtensionPointIdentifier
    ) -> Bool {
        return extensionPointIdentifier != UIApplication.ExtensionPointIdentifier.keyboard
    }
}

@main
struct SecantApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    init() {
        FontFamily.registerAllCustomFonts()
    }

    var body: some Scene {
        WindowGroup {
            RootView(
                store: appDelegate.rootStore,
                tokenName: TargetConstants.tokenName,
                networkType: TargetConstants.zcashNetwork.networkType
            )
        }
    }
}

// MARK: Zcash Network global type

/// Whenever the ZcashNetwork is required use this var to determine which is the
/// network type suitable for the present target.

public enum TargetConstants {
    public static var zcashNetwork: ZcashNetwork {
#if SECANT_MAINNET
    return ZcashNetworkBuilder.network(for: .mainnet)
#elseif SECANT_TESTNET
    return ZcashNetworkBuilder.network(for: .testnet)
#else
    fatalError("SECANT_MAINNET or SECANT_TESTNET flags not defined on Swift Compiler custom flags of your build target.")
#endif
    }
    
    public static var tokenName: String {
#if SECANT_MAINNET
    return "ZEC"
#elseif SECANT_TESTNET
    return "TAZ"
#else
    fatalError("SECANT_MAINNET or SECANT_TESTNET flags not defined on Swift Compiler custom flags of your build target.")
#endif
    }
}

extension SDKSynchronizerClient: DependencyKey {
    public static let liveValue: SDKSynchronizerClient = Self.live(network: TargetConstants.zcashNetwork)
}
