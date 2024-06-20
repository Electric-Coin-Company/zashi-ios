//
//  PrivateDataConsentStore.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 01.11.2023.
//

import Foundation
import ComposableArchitecture
import ZcashLightClientKit
import Models
import Generated
import Utils
import SwiftUI
import ExportLogs
import DatabaseFiles
import ExportLogs
import ZcashSDKEnvironment

public typealias PrivateDataConsentStore = Store<PrivateDataConsentReducer.State, PrivateDataConsentReducer.Action>
public typealias PrivateDataConsentViewStore = ViewStore<PrivateDataConsentReducer.State, PrivateDataConsentReducer.Action>

public struct PrivateDataConsentReducer: Reducer {
    public struct State: Equatable {
        public var exportBinding: Bool
        public var exportOnlyLogs = true
        @BindingState public var isAcknowledged: Bool = false
        public var isExportingData: Bool
        public var isExportingLogs: Bool
        public var dataDbURL: [URL] = []
        public var exportLogsState: ExportLogs.State
        
        public var isExportPossible: Bool {
            !isExportingData && !isExportingLogs && isAcknowledged
        }

        public var exportURLs: [URL] {
            exportOnlyLogs
            ? exportLogsState.zippedLogsURLs
            : dataDbURL + exportLogsState.zippedLogsURLs
        }
        
        public init(
            dataDbURL: [URL],
            exportBinding: Bool,
            exportLogsState: ExportLogs.State,
            exportOnlyLogs: Bool = true,
            isAcknowledged: Bool = false,
            isExportingData: Bool = false,
            isExportingLogs: Bool = false
        ) {
            self.dataDbURL = dataDbURL
            self.exportBinding = exportBinding
            self.exportLogsState = exportLogsState
            self.exportOnlyLogs = exportOnlyLogs
            self.isAcknowledged = isAcknowledged
            self.isExportingData = isExportingData
            self.isExportingLogs = isExportingLogs
        }
    }
    
    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<PrivateDataConsentReducer.State>)
        case exportLogs(ExportLogs.Action)
        case exportLogsRequested
        case exportRequested
        case onAppear
        case shareFinished
    }

    public init() { }

    @Dependency(\.databaseFiles) var databaseFiles
    @Dependency(\.walletStatusPanel) var walletStatusPanel
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    public var body: some Reducer<State, Action> {
        BindingReducer()

        Scope(state: \.exportLogsState, action: /Action.exportLogs) {
            ExportLogs()
        }
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.dataDbURL = [databaseFiles.dataDbURLFor(zcashSDKEnvironment.network)]
                return .none

            case .exportLogs(.finished):
                state.exportBinding = true
                return .none
                
            case .exportLogs:
                return .none

            case .exportLogsRequested:
                state.isExportingLogs = true
                state.exportOnlyLogs = true
                return .send(.exportLogs(.start))

            case .exportRequested:
                state.isExportingData = true
                state.exportOnlyLogs = false
                return .send(.exportLogs(.start))
                
            case .shareFinished:
                state.isExportingData = false
                state.isExportingLogs = false
                state.exportBinding = false
                return .none
                
            case .binding(\.$isAcknowledged):
                return .none
                
            case .binding:
                return .none
            }
        }
    }
}

// MARK: - Store

extension PrivateDataConsentStore {
    public static var demo = PrivateDataConsentStore(
        initialState: .initial
    ) {
        PrivateDataConsentReducer()
    }
}

// MARK: - Placeholders

extension PrivateDataConsentReducer.State {
    public static let initial = PrivateDataConsentReducer.State(
        dataDbURL: [],
        exportBinding: false,
        exportLogsState: .initial
    )
}
