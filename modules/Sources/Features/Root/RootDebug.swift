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
import Pasteboard

/// In this file is a collection of helpers that control all state and action related operations
/// for the `Root` with a connection to the UI navigation.
extension Root {
    public struct DebugState { }
    
    public indirect enum DebugAction {
        case cancelRescan
        case cantStartSync(ZcashError)
        case copySeedToPasteboard
        case flagUpdated
        case rateTheApp
        case rescanBlockchain
        case rewindDone(ZcashError?, Root.Action)
        case updateFlag(FeatureFlag, Bool)
        case walletConfigLoaded(WalletConfig)
    }

    // swiftlint:disable:next cyclomatic_complexity
    public func debugReduce() -> Reduce<Root.State, Root.Action> {
        Reduce { state, action in
            switch action {
            case .debug(.rescanBlockchain):
                state.confirmationDialog = ConfirmationDialogState.rescanRequest()
                return .none

            case .debug(.cancelRescan):
                state.confirmationDialog = nil
                return .none

            case .confirmationDialog(.presented(.quickRescan)):
                state.destinationState.destination = .tabs
                return rewind(policy: .quick, sourceAction: .quickRescan)

            case .confirmationDialog(.presented(.fullRescan)):
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
                return .publisher {
                    walletConfigProvider.update(flag, !isEnabled)
                        .receive(on: mainQueue)
                        .map { _ in return Action.debug(.flagUpdated) }
                }
                .cancellable(id: WalletConfigCancelId, cancelInFlight: true)

            case .debug(.flagUpdated):
                return .publisher {
                    walletConfigProvider.load()
                        .receive(on: mainQueue)
                        .map { Action.debug(.walletConfigLoaded($0)) }
                }
                .cancellable(id: WalletConfigCancelId, cancelInFlight: true)

            case .debug(.copySeedToPasteboard):
                let storedWallet = try? walletStorage.exportWallet()
                guard let phrase = storedWallet?.seedPhrase.value() else { return .none }
                pasteboard.setString(phrase.redacted)
                return .none
                
            case let .debug(.walletConfigLoaded(walletConfig)):
                return .send(.updateStateAfterConfigUpdate(walletConfig))

            case .debug(.cantStartSync(let error)):
                state.alert = AlertState.cantStartSync(error)
                return .none
                
            case .debug(.rateTheApp):
                return .none

            default: return .none
            }
        }
    }

    private func rewind(policy: RewindPolicy, sourceAction: Action.ConfirmationDialog) -> Effect<Root.Action> {
        Effect.publisher {
            sdkSynchronizer.rewind(policy)
                .replaceEmpty(with: Void())
                .map { _ in
                    Root.Action.debug(.rewindDone(nil, .confirmationDialog(.presented(sourceAction))))
                }
                .catch { error in
                    Just(
                        Root.Action.debug(.rewindDone(error.toZcashError(), .confirmationDialog(.presented(sourceAction))))
                    )
                    .eraseToAnyPublisher()
                }
                .receive(on: mainQueue)
        }
        .cancellable(id: SynchronizerCancelId, cancelInFlight: true)
    }
}

// MARK: Placeholders

extension Root.DebugState {
    public static var initial: Self {
        .init()
    }
}
