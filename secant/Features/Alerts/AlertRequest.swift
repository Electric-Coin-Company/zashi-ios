//
//  AlertRequest.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 29.03.2023.
//

import Foundation
import ComposableArchitecture

extension RootReducer {
    indirect enum AlertAction: Equatable {
        case balanceBreakdown(BalanceBreakdownReducer.Action?)
        case exportLogs(ExportLogsReducer.Action?)
        case home(HomeReducer.Action?)
        case importWallet(ImportWalletReducer.Action?)
        case root(RootReducer.Action?)
        case scan(ScanReducer.Action?)
        case settings(SettingsReducer.Action?)
        case walletEvents(WalletEventsFlowReducer.Action?)
    }
}

enum AlertRequest: Equatable {
    enum BalanceBreakdown: Equatable {
        case shieldFundsSuccess
        case shieldFundsFailure(String)
    }

    enum ExportLogs: Equatable {
        case failed(String)
    }

    enum Home: Equatable {
        case syncFailed(String, String)
    }

    enum ImportWallet: Equatable {
        case succeed
        case failed(String)
    }

    enum Root: Equatable {
        case cantCreateNewWallet(String)
        case cantLoadSeedPhrase
        case cantStartSync(String)
        case cantStoreThatUserPassedPhraseBackupTest(String)
        case failedToProcessDeeplink(URL, String)
        case initializationFailed(String)
        case rewindFailed(String)
        case walletStateFailed(InitializationState)
        case wipeFailed
        case wipeRequest
    }

    enum Scan: Equatable {
        case cantInitializeCamera(String)
    }

    enum Settings: Equatable {
        case cantBackupWallet(String)
        case sendSupportMail
    }

    enum WalletEvents: Equatable {
        case warnBeforeLeavingApp(URL?)
    }

    case balanceBreakdown(BalanceBreakdown)
    case exportLogs(ExportLogs)
    case home(Home)
    case importWallet(ImportWallet)
    case root(Root)
    case scan(Scan)
    case settings(Settings)
    case walletEvents(WalletEvents)

    func alertState() -> AlertState<RootReducer.Action> {
        switch self {
        case .balanceBreakdown(let balanceBreakdown):
            return balanceBreakdownAlertState(balanceBreakdown)
        case .exportLogs(let exportLogs):
            return exportLogsAlertState(exportLogs)
        case .home(let home):
            return homeAlertState(home)
        case .importWallet(let importWallet):
            return importWalletAlertState(importWallet)
        case .root(let root):
            return rootAlertState(root)
        case .scan(let scan):
            return scanAlertState(scan)
        case .settings(let settings):
            return settingsAlertState(settings)
        case .walletEvents(let walletEvents):
            return walletEventsAlertState(walletEvents)
        }
    }
}
