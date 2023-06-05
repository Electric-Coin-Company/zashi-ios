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
import LogsHandler
import Utils
import Generated

typealias ExportLogsStore = Store<ExportLogsReducer.State, ExportLogsReducer.Action>
typealias ExportLogsViewStore = ViewStore<ExportLogsReducer.State, ExportLogsReducer.Action>

struct ExportLogsReducer: ReducerProtocol {
    struct State: Equatable {
        @PresentationState var alert: AlertState<Action>?
        var exportLogsDisabled = false
        var isSharingLogs = false
        var zippedLogsURLs: [URL] = []
    }

    indirect enum Action: Equatable {
        case alert(PresentationAction<Action>)
        case start
        case finished(URL?)
        case failed(ZcashError)
        case shareFinished
    }

    @Dependency(\.logsHandler) var logsHandler

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .alert:
                return .none

            case .start:
                state.exportLogsDisabled = true
                return .run { send in
                    do {
                        let zippedLogsURL = try await logsHandler.exportAndStoreLogs(
                            LoggerConstants.sdkLogs,
                            LoggerConstants.tcaLogs,
                            LoggerConstants.walletLogs
                        )
                        await send(.finished(zippedLogsURL))
                    } catch {
                        await send(.failed(error.toZcashError()))
                    }
                }

            case .finished(let zippedLogsURL):
                if let zippedLogsURL {
                    state.zippedLogsURLs = [zippedLogsURL]
                }
                state.exportLogsDisabled = false
                state.isSharingLogs = true
                return .none

            case let .failed(error):
                state.exportLogsDisabled = false
                state.isSharingLogs = false
                state.alert = AlertState.failed(error)
                return .none

            case .shareFinished:
                state.isSharingLogs = false
                return .none
            }
        }
    }
}

// MARK: Alerts

extension AlertState where Action == ExportLogsReducer.Action {
    static func failed(_ error: ZcashError) -> AlertState<ExportLogsReducer.Action> {
        AlertState<ExportLogsReducer.Action> {
            TextState(L10n.ExportLogs.Alert.Failed.title)
        } message: {
            TextState(L10n.ExportLogs.Alert.Failed.message(error.message, error.code.rawValue))
        }
    }
}

// MARK: Placeholders

extension ExportLogsReducer.State {
    static var placeholder: Self {
        .init()
    }
}
