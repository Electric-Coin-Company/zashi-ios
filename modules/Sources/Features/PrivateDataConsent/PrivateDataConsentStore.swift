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

public typealias PrivateDataConsentStore = Store<PrivateDataConsentReducer.State, PrivateDataConsentReducer.Action>
public typealias PrivateDataConsentViewStore = ViewStore<PrivateDataConsentReducer.State, PrivateDataConsentReducer.Action>

public struct PrivateDataConsentReducer: Reducer {
    let networkType: NetworkType

    public struct State: Equatable {
        @BindingState public var isAcknowledged: Bool = false
        public var isExporting: Bool
        public var dataDbURL: [URL] = []
        
        public init(
            isExporting: Bool,
            dataDbURL: [URL]
        ) {
            self.isExporting = isExporting
            self.dataDbURL = dataDbURL
        }
    }
    
    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<PrivateDataConsentReducer.State>)
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

        Reduce { state, action in
            switch action {
            case .onAppear:
                state.dataDbURL = [databaseFiles.dataDbURLFor(ZcashNetworkBuilder.network(for: networkType))]
                return .none
                
            case .exportRequested:
                state.isExporting = true
                return .none

            case .shareFinished:
                state.isExporting = false
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
        isExporting: false,
        dataDbURL: []
    )
}
