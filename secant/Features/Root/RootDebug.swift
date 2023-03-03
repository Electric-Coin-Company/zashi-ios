//
//  RootDebug.swift
//  secant
//
//  Created by Lukáš Korba on 02.03.2023.
//

import Combine
import ComposableArchitecture
import Foundation
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
                return rewind(policy: .quick, sourceAction: .quickRescan)

            case .debug(.fullRescan):
                state.destinationState.destination = .home
                return rewind(policy: .birthday, sourceAction: .fullRescan)

            case let .debug(.rewindDone(errorDescription, _)):
                if let errorDescription {
                    // TODO: [#221] Handle error more properly (https://github.com/zcash/secant-ios-wallet/issues/221)
                    state.alert = AlertState(
                        title: TextState("Rewind failed"),
                        message: TextState("Error: \(errorDescription)"),
                        dismissButton: .default(TextState("Ok"), action: .send(.dismissAlert))
                    )
                } else {
                    do {
                        try sdkSynchronizer.start()
                    } catch {
                        // TODO: [#221] Handle error more properly (https://github.com/zcash/secant-ios-wallet/issues/221)
                        state.alert = AlertState(
                            title: TextState("Can't start sync process after rewind"),
                            message: TextState("Error: \(error.localizedDescription)"),
                            dismissButton: .default(TextState("Ok"), action: .send(.dismissAlert))
                        )
                    }
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

    private func rewind(policy: RewindPolicy, sourceAction: DebugAction) -> EffectPublisher<RootReducer.Action, Never> {
        guard let rewindPublisher = sdkSynchronizer.rewind(policy) else {
            return EffectTask(value: .debug(.rewindDone("SDKSynchronizer not initilized. rewindPublisher is nil", .debug(sourceAction))))
        }
        return rewindPublisher
            .replaceEmpty(with: Void())
            .map { _ in return RootReducer.Action.debug(.rewindDone(nil, .debug(sourceAction))) }
            .catch { error in
                return Just(RootReducer.Action.debug(.rewindDone(error.localizedDescription, .debug(sourceAction)))).eraseToAnyPublisher()
            }
            .receive(on: mainQueue)
            .eraseToEffect()
            .cancellable(id: SynchronizerCancelId.self, cancelInFlight: true)
    }
}

// MARK: Placeholders

extension RootReducer.DebugState {
    static var placeholder: Self {
        .init()
    }
}
