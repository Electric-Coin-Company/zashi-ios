//
//  ExportTransactionHistoryStore.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-02-13.
//

import Foundation
import ComposableArchitecture
import ZcashLightClientKit
import SwiftUI
import TaxExporter
import Models

@Reducer
public struct ExportTransactionHistory {
    @ObservableState
    public struct State: Equatable {
        public var exportBinding = false
        public var isExportingData = false
        public var dataURL: URL = .emptyURL
        @Shared(.inMemory(.selectedWalletAccount)) public var selectedWalletAccount: WalletAccount? = nil
        @Shared(.inMemory(.transactions)) public var transactions: IdentifiedArrayOf<TransactionState> = []

        public var isExportPossible: Bool {
            !isExportingData
        }
        
        public var accountName: String {
            selectedWalletAccount?.vendor.name() ?? ""
        }

        public init() { }
    }
    
    public enum Action: Equatable {
        case exportRequested
        case preparationOfUrlsFailed
        case shareFinished
        case urlsPrepared(URL)
    }

    public init() { }

    @Dependency(\.taxExporter) var taxExporter

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .exportRequested:
                guard let account = state.selectedWalletAccount else {
                    return .none
                }
                state.isExportingData = true
                let accountName = account.vendor.name()
                do {
                    let url = try taxExporter.cointrackerCSVfor(state.transactions.elements, accountName)
                    return .send(.urlsPrepared(url))
                } catch {
                    return .send(.preparationOfUrlsFailed)
                }

            case .preparationOfUrlsFailed:
                state.isExportingData = false
                return .none
                
            case .urlsPrepared(let url):
                state.dataURL = url
                state.exportBinding = true
                return .none

            case .shareFinished:
                state.isExportingData = false
                state.exportBinding = false
                return .none
            }
        }
    }
}
