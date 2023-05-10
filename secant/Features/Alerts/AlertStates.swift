//
//  AlertStates.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 29.03.2023.
//

import ComposableArchitecture

// MARK: - Balance Breakdown

extension AlertRequest {
    func balanceBreakdownAlertState(_ balanceBreakdown: BalanceBreakdown) -> AlertState<RootReducer.Action> {
        switch balanceBreakdown {
        case .shieldFundsFailure(let error):
            return AlertState(
                title: TextState(L10n.BalanceBreakdown.Alert.ShieldFunds.Failure.title),
                message: TextState(L10n.BalanceBreakdown.Alert.ShieldFunds.Failure.message(error.message, error.code.rawValue)),
                dismissButton: .default(TextState(L10n.General.ok), action: .send(.dismissAlert))
            )
        case .shieldFundsSuccess:
            return AlertState(
                title: TextState(L10n.BalanceBreakdown.Alert.ShieldFunds.Success.title),
                message: TextState(L10n.BalanceBreakdown.Alert.ShieldFunds.Success.message),
                dismissButton: .default(TextState(L10n.General.ok), action: .send(.dismissAlert))
            )
        }
    }
}

// MARK: - Export Logs

extension AlertRequest {
    func exportLogsAlertState(_ exportLogs: ExportLogs) -> AlertState<RootReducer.Action> {
        switch exportLogs {
        case .failed(let error):
            return AlertState(
                title: TextState(L10n.ExportLogs.Alert.Failed.title),
                message: TextState(L10n.ExportLogs.Alert.Failed.message(error.message, error.code.rawValue)),
                dismissButton: .default(TextState(L10n.General.ok), action: .send(.dismissAlert))
            )
        }
    }
}

// MARK: - Home

extension AlertRequest {
    func homeAlertState(_ home: Home) -> AlertState<RootReducer.Action> {
        switch home {
        case let .syncFailed(error, secondaryButtonTitle):
            return AlertState(
                title: TextState(L10n.Home.SyncFailed.title),
                message: TextState("\(error.message) (code: \(error.code.rawValue))"),
                primaryButton: .default(TextState(L10n.Home.SyncFailed.retry), action: .send(.uniAlert(.home(.retrySync)))),
                secondaryButton: .default(TextState(secondaryButtonTitle), action: .send(.dismissAlert))
            )
        }
    }
}

// MARK: - Import Wallet

extension AlertRequest {
    func importWalletAlertState(_ importWallet: ImportWallet) -> AlertState<RootReducer.Action> {
        switch importWallet {
        case .succeed:
            return AlertState(
                title: TextState(L10n.General.success),
                message: TextState(L10n.ImportWallet.Alert.Success.message),
                dismissButton: .default(TextState(L10n.General.ok), action: .send(.uniAlert(.importWallet(.successfullyRecovered))))
            )
        case .failed(let error):
            return AlertState(
                title: TextState(L10n.ImportWallet.Alert.Failed.title),
                message: TextState(L10n.ImportWallet.Alert.Failed.message(error.message, error.code.rawValue)),
                dismissButton: .default(TextState(L10n.General.ok), action: .send(.dismissAlert))
            )
        }
    }
}

// MARK: - Root

extension AlertRequest {
    func rootAlertState(_ root: Root) -> AlertState<RootReducer.Action> {
        switch root {
        case .cantCreateNewWallet(let error):
            return AlertState(
                title: TextState(L10n.Root.Initialization.Alert.Failed.title),
                message: TextState(L10n.Root.Initialization.Alert.CantCreateNewWallet.message(error.message, error.code.rawValue)),
                dismissButton: .default(TextState(L10n.General.ok), action: .send(.dismissAlert))
            )
        case .cantLoadSeedPhrase:
            return AlertState(
                title: TextState(L10n.Root.Initialization.Alert.Failed.title),
                message: TextState(L10n.Root.Initialization.Alert.CantLoadSeedPhrase.message),
                dismissButton: .default(TextState(L10n.General.ok), action: .send(.dismissAlert))
            )
        case .cantStartSync(let error):
            return AlertState(
                title: TextState(L10n.Root.Debug.Alert.Rewind.CantStartSync.title),
                message: TextState(L10n.Root.Debug.Alert.Rewind.CantStartSync.message(error.message, error.code.rawValue)),
                dismissButton: .default(TextState(L10n.General.ok), action: .send(.dismissAlert))
            )
        case .cantStoreThatUserPassedPhraseBackupTest(let error):
            return AlertState(
                title: TextState(L10n.Root.Initialization.Alert.Failed.title),
                message: TextState(L10n.Root.Initialization.Alert.CantStoreThatUserPassedPhraseBackupTest.message(error.message, error.code.rawValue)),
                dismissButton: .default(TextState(L10n.General.ok), action: .send(.dismissAlert))
            )
        case let .failedToProcessDeeplink(url, error):
            return AlertState(
                title: TextState(L10n.Root.Destination.Alert.FailedToProcessDeeplink.title),
                message: TextState(L10n.Root.Destination.Alert.FailedToProcessDeeplink.message(url, error.message, error.code.rawValue)),
                dismissButton: .default(TextState(L10n.General.ok), action: .send(.dismissAlert))
            )
        case .initializationFailed(let error):
            return AlertState(
                title: TextState(L10n.Root.Initialization.Alert.SdkInitFailed.title),
                message: TextState(L10n.Root.Initialization.Alert.Error.message(error.message, error.code.rawValue)),
                dismissButton: .default(TextState(L10n.General.ok), action: .send(.dismissAlert))
            )
        case .rewindFailed(let error):
            return AlertState(
                title: TextState(L10n.Root.Debug.Alert.Rewind.Failed.title),
                message: TextState(L10n.Root.Debug.Alert.Rewind.Failed.message(error.message, error.code.rawValue)),
                dismissButton: .default(TextState(L10n.General.ok), action: .send(.dismissAlert))
            )
        case .walletStateFailed(let walletState):
            return AlertState(
                title: TextState(L10n.Root.Initialization.Alert.Failed.title),
                message: TextState(L10n.Root.Initialization.Alert.WalletStateFailed.message(walletState)),
                dismissButton: .default(TextState(L10n.General.ok), action: .send(.dismissAlert))
            )
        case .wipeFailed:
            return AlertState(
                title: TextState(L10n.Root.Initialization.Alert.WipeFailed.title),
                message: TextState(""),
                dismissButton: .default(TextState(L10n.General.ok), action: .send(.dismissAlert))
            )
        case .wipeRequest:
            return AlertState(
                title: TextState(L10n.Root.Initialization.Alert.Wipe.title),
                message: TextState(L10n.Root.Initialization.Alert.Wipe.message),
                buttons: [
                    .destructive(TextState(L10n.General.yes), action: .send(.initialization(.nukeWallet))),
                    .cancel(TextState(L10n.General.no), action: .send(.dismissAlert))
                ]
            )
        }
    }
}

// MARK: - Scan

extension AlertRequest {
    func scanAlertState(_ scan: Scan) -> AlertState<RootReducer.Action> {
        switch scan {
        case .cantInitializeCamera(let error):
            return AlertState(
                title: TextState(L10n.Scan.Alert.CantInitializeCamera.title),
                message: TextState(L10n.Scan.Alert.CantInitializeCamera.message(error.message, error.code.rawValue)),
                dismissButton: .default(TextState(L10n.General.ok), action: .send(.dismissAlert))
            )
        }
    }
}

// MARK: - Settings

extension AlertRequest {
    func settingsAlertState(_ settings: Settings) -> AlertState<RootReducer.Action> {
        switch settings {
        case .cantBackupWallet(let error):
            return AlertState<RootReducer.Action>(
                title: TextState(L10n.Settings.Alert.CantBackupWallet.title),
                message: TextState(L10n.Settings.Alert.CantBackupWallet.message(error.message, error.code.rawValue)),
                dismissButton: .default(TextState(L10n.General.ok), action: .send(.dismissAlert))
            )
        case .sendSupportMail:
            return AlertState<RootReducer.Action>(
                title: TextState(L10n.Settings.Alert.CantSendEmail.title),
                message: TextState(L10n.Settings.Alert.CantSendEmail.message),
                dismissButton: .default(TextState(L10n.General.ok), action: .send(.uniAlert(.settings(.sendSupportMailFinished))))
            )
        }
    }
}

// MARK: - Wallet Events

extension AlertRequest {
    func walletEventsAlertState(_ walletEvents: WalletEvents) -> AlertState<RootReducer.Action> {
        switch walletEvents {
        case .warnBeforeLeavingApp(let blockExplorerURL):
            return AlertState(
                title: TextState(L10n.WalletEvent.Alert.LeavingApp.title),
                message: TextState(L10n.WalletEvent.Alert.LeavingApp.message),
                primaryButton: .cancel(
                    TextState(L10n.WalletEvent.Alert.LeavingApp.Button.nevermind),
                    action: .send(.dismissAlert)
                ),
                secondaryButton: .default(
                    TextState(L10n.WalletEvent.Alert.LeavingApp.Button.seeOnline),
                    action: .send(.uniAlert(.walletEvents(.openBlockExplorer(blockExplorerURL))))
                )
            )
        }
    }
}
