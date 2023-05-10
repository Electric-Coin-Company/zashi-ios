//
//  AlertRequest.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 29.03.2023.
//

import Foundation
import ComposableArchitecture
import ZcashLightClientKit

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
        case shieldFundsFailure(ZcashError)
    }

    enum ExportLogs: Equatable {
        case failed(ZcashError)
    }

    enum Home: Equatable {
        case syncFailed(ZcashError, String)
    }

    enum ImportWallet: Equatable {
        case succeed
        case failed(ZcashError)
    }

    enum Root: Equatable {
        case cantCreateNewWallet(ZcashError)
        case cantLoadSeedPhrase
        case cantStartSync(ZcashError)
        case cantStoreThatUserPassedPhraseBackupTest(ZcashError)
        case failedToProcessDeeplink(URL, ZcashError)
        case initializationFailed(ZcashError)
        case rewindFailed(ZcashError)
        case walletStateFailed(InitializationState)
        case wipeFailed
        case wipeRequest
    }

    enum Scan: Equatable {
        case cantInitializeCamera(ZcashError)
    }

    enum Settings: Equatable {
        case cantBackupWallet(ZcashError)
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
