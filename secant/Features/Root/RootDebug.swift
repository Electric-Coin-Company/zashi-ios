//
//  RootDebug.swift
//  secant
//
//  Created by Lukáš Korba on 02.03.2023.
//

import Foundation
import ComposableArchitecture
import ZcashLightClientKit

/// In this file is a collection of helpers that control all state and action related operations
/// for the `RootReducer` with a connection to the UI navigation.
extension RootReducer {
    struct DebugState: Equatable {
        var rescanDialog: ConfirmationDialogState<RootReducer.Action>?
    }
    
    indirect enum DebugAction: Equatable {
        case cancelRescan
        case flagUpdated
        case fullRescan
        case quickRescan
        case rescanBlockchain
        case rewindDone(String?, RootReducer.Action)
        case testCrashReporter // this will crash the app if live.
        case updateFlag(FeatureFlag, Bool)
        case walletConfigLoaded(WalletConfig)
    }

    // swiftlint:disable:next cyclomatic_complexity
    func debugReduce() -> Reduce<RootReducer.State, RootReducer.Action> {
        Reduce { state, action in
            switch action {
            case .debug(.testCrashReporter):
                crashReporter.testCrash()
                return .none
                
            case .debug(.rescanBlockchain):
                state.debugState.rescanDialog = .init(
                    title: TextState("Rescan"),
                    message: TextState("Select the rescan you want"),
                    buttons: [
                        .default(TextState("Quick rescan"), action: .send(.debug(.quickRescan))),
                        .default(TextState("Full rescan"), action: .send(.debug(.fullRescan))),
                        .cancel(TextState("Cancel"))
                    ]
                )
                return .none

            case .debug(.cancelRescan):
                state.debugState.rescanDialog = nil
                return .none

            case .debug(.quickRescan):
                state.destinationState.destination = .home
                return .run { send in
                    do {
                        try await sdkSynchronizer.rewind(.quick)
                        await send(.debug(.rewindDone(nil, .debug(.quickRescan))))
                    } catch {
                        await send(.debug(.rewindDone(error.localizedDescription, .debug(.quickRescan))))
                    }
                }

            case .debug(.fullRescan):
                state.destinationState.destination = .home
                return .run { send in
                    do {
                        try await sdkSynchronizer.rewind(.birthday)
                        await send(.debug(.rewindDone(nil, .debug(.fullRescan))))
                    } catch {
                        await send(.debug(.rewindDone(error.localizedDescription, .debug(.fullRescan))))
                    }
                }

            case let .debug(.rewindDone(errorDescription, _)):
                if let errorDescription {
                    // TODO: [#221] Handle error more properly (https://github.com/zcash/secant-ios-wallet/issues/221)
                    state.alert = AlertState(
                        title: TextState("Rewind failed"),
                        message: TextState("Error: \(errorDescription)"),
                        dismissButton: .default(TextState("Ok"), action: .send(.dismissAlert))
                    )
                }
                return .none
                
            case let .debug(.updateFlag(flag, isEnabled)):
                return walletConfigProvider.update(flag, !isEnabled)
                    .receive(on: mainQueue)
                    .map { _ in return Action.debug(.flagUpdated) }
                    .eraseToEffect()
                    .cancellable(id: WalletConfigCancelId.self, cancelInFlight: true)

            case .debug(.flagUpdated):
                return walletConfigProvider.load()
                    .receive(on: mainQueue)
                    .map { Action.debug(.walletConfigLoaded($0)) }
                    .eraseToEffect()
                    .cancellable(id: WalletConfigCancelId.self, cancelInFlight: true)

            case let .debug(.walletConfigLoaded(walletConfig)):
                return EffectTask(value: .updateStateAfterConfigUpdate(walletConfig))

            default: return .none
            }
        }
    }
}

// MARK: Placeholders

extension RootReducer.DebugState {
    static var placeholder: Self {
        .init()
    }
}
