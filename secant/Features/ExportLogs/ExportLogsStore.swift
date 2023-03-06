//
//  ExportLogsStore.swift
//  secant
//
//  Created by Michal Fousek on 06.03.2023.
//

import Combine
import ComposableArchitecture
import Foundation
import ZcashLightClientKit

typealias ExportLogsStore = Store<ExportLogsReducer.State, ExportLogsReducer.Action>
typealias ExportLogsViewStore = ViewStore<ExportLogsReducer.State, ExportLogsReducer.Action>

struct ExportLogsReducer: ReducerProtocol {
    struct State: Equatable {
        @BindingState var alert: AlertState<ExportLogsReducer.Action>?
        var exportLogsDisabled = false
        var isSharingLogs = false
        var tempSDKDir: URL {
            let tempDir = FileManager.default.temporaryDirectory
            let sdkFileName = "sdkLogs.txt"
            return tempDir.appendingPathComponent(sdkFileName)
        }

        var tempTCADir: URL {
            let tempDir = FileManager.default.temporaryDirectory
            let sdkFileName = "tcaLogs.txt"
            return tempDir.appendingPathComponent(sdkFileName)
        }

        var tempWalletDir: URL {
            let tempDir = FileManager.default.temporaryDirectory
            let sdkFileName = "walletLogs.txt"
            return tempDir.appendingPathComponent(sdkFileName)
        }
    }

    indirect enum Action: Equatable, BindableAction {
        case binding(BindingAction<ExportLogsReducer.State>)
        case dismissAlert
        case start
        case finished
        case failed(String)
        case shareFinished
    }

    @Dependency(\.logsHandler) var logsHandler

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .dismissAlert:
                state.exportLogsDisabled = false
                state.isSharingLogs = false
                state.alert = nil
                return .none

            case .start:
                state.exportLogsDisabled = true
                return .run { [state] send in
                    do {
                        try await logsHandler.exportAndStoreLogs(state.tempSDKDir, state.tempTCADir, state.tempWalletDir)
                        await send(.finished)
                    } catch {
                        await send(.failed(error.localizedDescription))
                    }
                }

            case .finished:
                state.exportLogsDisabled = false
                state.isSharingLogs = true
                return .none

            case let .failed(errorDescription):
                // TODO: [#527] address the error here https://github.com/zcash/secant-ios-wallet/issues/527
                state.alert = AlertState(
                    title: TextState("Error when exporting logs"),
                    message: TextState("Error: \(errorDescription)"),
                    dismissButton: .default(TextState("Ok"), action: .send(.dismissAlert))
                )
                return .none

            case .shareFinished:
                state.isSharingLogs = false
                return .none
            }
        }
    }
}

// MARK: Placeholders

extension ExportLogsReducer.State {
    static var placeholder: Self {
        .init()
    }
}
