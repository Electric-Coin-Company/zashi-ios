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
        case cantStartSync(ZcashError)
        case flagUpdated
        case fullRescan
        case quickRescan
        case rateTheApp
        case rescanBlockchain
        case rewindDone(ZcashError?, RootReducer.Action)
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
                    title: TextState(L10n.Root.Debug.Dialog.Rescan.title),
                    message: TextState(L10n.Root.Debug.Dialog.Rescan.message),
                    buttons: [
                        .default(TextState(L10n.Root.Debug.Dialog.Rescan.Option.quick), action: .send(.debug(.quickRescan))),
                        .default(TextState(L10n.Root.Debug.Dialog.Rescan.Option.full), action: .send(.debug(.fullRescan))),
                        .cancel(TextState(L10n.General.cancel))
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

            case let .debug(.rewindDone(error, _)):
                if let error {
                    return EffectTask(value: .alert(.root(.rewindFailed(error.toZcashError()))))
                } else {
                    return .run { send in
                        do {
                            try await sdkSynchronizer.start(false)
                        } catch {
                            await send(.debug(.cantStartSync(error.toZcashError())))
                        }
                    }
                }
                
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

            case .debug(.cantStartSync(let error)):
                return EffectTask(value: .alert(.root(.cantStartSync(error))))
                
            case .debug(.rateTheApp):
                return .none
                
            default: return .none
            }
        }
    }

    private func rewind(policy: RewindPolicy, sourceAction: DebugAction) -> EffectPublisher<RootReducer.Action, Never> {
        return sdkSynchronizer.rewind(policy)
            .replaceEmpty(with: Void())
            .map { _ in return RootReducer.Action.debug(.rewindDone(nil, .debug(sourceAction))) }
            .catch { error in
                return Just(RootReducer.Action.debug(.rewindDone(error.toZcashError(), .debug(sourceAction)))).eraseToAnyPublisher()
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
