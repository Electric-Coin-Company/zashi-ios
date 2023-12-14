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

public typealias PrivateDataConsentStore = Store<PrivateDataConsentReducer.State, PrivateDataConsentReducer.Action>
public typealias PrivateDataConsentViewStore = ViewStore<PrivateDataConsentReducer.State, PrivateDataConsentReducer.Action>

public struct PrivateDataConsentReducer: Reducer {
    let networkType: NetworkType

    public struct State: Equatable {
        @BindingState public var isAcknowledged: Bool = false
        public var exportBinding: Bool
        public var exportOnlyLogs = true
        public var isExportingData: Bool
        public var isExportingLogs: Bool
        public var dataDbURL: [URL] = []
        public var exportLogsState: ExportLogsReducer.State
        
        public var isExportPossible: Bool {
            !isExportingData && !isExportingLogs && isAcknowledged
        }

        public var exportURLs: [URL] {
            exportOnlyLogs
            ? exportLogsState.zippedLogsURLs
            : dataDbURL + exportLogsState.zippedLogsURLs
        }
        
        public init(
            isAcknowledged: Bool = false,
            dataDbURL: [URL],
            exportBinding: Bool,
            exportLogsState: ExportLogsReducer.State,
            exportOnlyLogs: Bool = true,
            isExportingData: Bool = false,
            isExportingLogs: Bool = false
        ) {
            self.isAcknowledged = isAcknowledged
            self.dataDbURL = dataDbURL
            self.exportBinding = exportBinding
            self.exportLogsState = exportLogsState
            self.exportOnlyLogs = exportOnlyLogs
            self.isExportingData = isExportingData
            self.isExportingLogs = isExportingLogs
        }
    }
    
    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<PrivateDataConsentReducer.State>)
        case exportLogs(ExportLogsReducer.Action)
        case exportLogsRequested
        case exportRequested
        case onAppear
        case shareFinished
    }

    public init(networkType: NetworkType) {
        self.networkType = networkType
    }

    @Dependency(\.databaseFiles) var databaseFiles

    public var body: some Reducer<State, Action> {
        BindingReducer()

        Scope(state: \.exportLogsState, action: /Action.exportLogs) {
            ExportLogsReducer()
        }
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.dataDbURL = [databaseFiles.dataDbURLFor(ZcashNetworkBuilder.network(for: networkType))]
                state.isAcknowledged = false
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
        PrivateDataConsentReducer(networkType: .testnet)
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
