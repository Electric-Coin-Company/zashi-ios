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
        var exportLogsDisabled = false
        var isSharingLogs = false
        var zippedLogsURLs: [URL] = []
    }

    indirect enum Action: Equatable {
        case alert(AlertRequest)
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
                        let zippedLogsURL = try await logsHandler.exportAndStoreLogs()
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
                return EffectTask(value: .alert(.exportLogs(.failed(error))))

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
