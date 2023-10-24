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
import Generated
import Models

/// In this file is a collection of helpers that control all state and action related operations
/// for the `RootReducer` with a connection to the UI navigation.
extension RootReducer {
    public struct DebugState: Equatable {
        @PresentationState public var rescanDialog: ConfirmationDialogState<Action>?
    }
    
    public indirect enum DebugAction: Equatable {
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
    public func debugReduce() -> Reduce<RootReducer.State, RootReducer.Action> {
        Reduce { state, action in
            switch action {
            case .debug(.testCrashReporter):
                crashReporter.testCrash()
                return .none
                
            case .debug(.rescanBlockchain):
                state.debugState.rescanDialog = ConfirmationDialogState.rescanRequest()
                return .none

            case .debug(.cancelRescan):
                state.debugState.rescanDialog = nil
                return .none

            case .debug(.quickRescan):
                state.destinationState.destination = .tabs
                return rewind(policy: .quick, sourceAction: .quickRescan)

            case .debug(.fullRescan):
                state.destinationState.destination = .tabs
                return rewind(policy: .birthday, sourceAction: .fullRescan)

            case let .debug(.rewindDone(error, _)):
                if let error {
                    state.alert = AlertState.rewindFailed(error.toZcashError())
                    return .none
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
                    .cancellable(id: WalletConfigCancelId.timer, cancelInFlight: true)

            case .debug(.flagUpdated):
                return walletConfigProvider.load()
                    .receive(on: mainQueue)
                    .map { Action.debug(.walletConfigLoaded($0)) }
                    .eraseToEffect()
                    .cancellable(id: WalletConfigCancelId.timer, cancelInFlight: true)

            case let .debug(.walletConfigLoaded(walletConfig)):
                return Effect.send(.updateStateAfterConfigUpdate(walletConfig))

            case .debug(.cantStartSync(let error)):
                state.alert = AlertState.cantStartSync(error)
                return .none
                
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
            .cancellable(id: SynchronizerCancelId.timer, cancelInFlight: true)
    }
}

// MARK: Placeholders

extension RootReducer.DebugState {
    public static var placeholder: Self {
        .init()
    }
}
