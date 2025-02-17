//
//  ExportTransactionHistoryStore.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-02-13.
//

import Foundation
import ComposableArchitecture
import ZcashLightClientKit
import Models
import Generated
import Utils
import SwiftUI
import ZcashSDKEnvironment
import TaxExporter
import SDKSynchronizer

@Reducer
public struct ExportTransactionHistory {
    @ObservableState
    public struct State: Equatable {
        public var exportBinding = false
        public var isExportingData = false
        public var dataURL: URL = .emptyURL
        @Shared(.inMemory(.selectedWalletAccount)) public var selectedWalletAccount: WalletAccount? = nil

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
        case onAppear
        case preparationOfUrlsFailed
        case shareFinished
        case urlsPrepared(URL)
    }

    public init() { }

    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.taxExporter) var taxExporter
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none

            case .exportRequested:
                guard let account = state.selectedWalletAccount else {
                    return .none
                }
                state.isExportingData = true
                return .run { send in
                    var url: URL = .emptyURL

                    if let transactions = try? await sdkSynchronizer.getAllTransactions(account.id) {
                        let accountName = account.vendor.name()
                        do {
                            url = try taxExporter.cointrackerCSVfor(transactions, accountName)
                        } catch {
                            await send(.preparationOfUrlsFailed)
                        }
                    }
                    
                    await send(.urlsPrepared(url))
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
