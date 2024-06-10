//
//  WalletStatusPanelInterface.swift
//
//
//  Created by Lukáš Korba on 19.12.2023.
//

import Foundation
import ComposableArchitecture
import Combine
import Generated

public enum WalletStatus: Equatable {
    case none
    case restoring
    case disconnected
    
    public func text() -> String {
        switch self {
        case .restoring: return L10n.WalletStatus.restoringWallet
        case .disconnected: return L10n.WalletStatus.disconnected
        default: return ""
        }
    }
}

extension DependencyValues {
    public var walletStatusPanel: WalletStatusPanelClient {
        get { self[WalletStatusPanelClient.self] }
        set { self[WalletStatusPanelClient.self] = newValue }
    }
}

public struct WalletStatusPanelClient {
    public var value: @Sendable () -> CurrentValueSubject<WalletStatus, Never>
    public var updateValue: @Sendable (WalletStatus) -> Void
}
