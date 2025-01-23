//
//  TransactionsManagerView.swift
//  Zashi
//
//  Created by Lukáš Korba on 01-22-2025.
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents
import Models
import ZcashLightClientKit
import AddressBook

public struct TransactionsManagerView: View {
    @Perception.Bindable var store: StoreOf<TransactionsManager>
    let tokenName: String
    
    public init(store: StoreOf<TransactionsManager>, tokenName: String) {
        self.store = store
        self.tokenName = tokenName
    }

    public var body: some View {
        WithPerceptionTracking {
            List {
                if store.isInvalidated {
                    VStack {
                        ProgressView()
                    }
                    .frame(maxWidth: .infinity)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Asset.Colors.background.color)
                    .listRowSeparator(.hidden)
                    .padding(.top, 30)
                } else {
                    Text("Previous 7 days")
                        .zFont(.medium, size: 16, style: Design.Text.tertiary)
                        .screenHorizontalPadding()
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Asset.Colors.background.color)
                        .listRowSeparator(.hidden)

                    ForEach(store.transactionList) { transaction in
                        WithPerceptionTracking {
                            Button {
                                store.send(.transactionTapped(transaction.id))
                            } label: {
                                TransactionRowView(
                                    transaction: transaction,
                                    isLatestTransaction: store.latestTransactionId == transaction.id
                                )
                            }
                            .listRowInsets(EdgeInsets())
                        }
                    }
                    .listRowBackground(Asset.Colors.background.color)
                    .listRowSeparator(.hidden)
                }
            }
            .padding(.vertical, 1)
            .disabled(store.transactionList.isEmpty)
            .applyScreenBackground()
            .listStyle(.plain)
            .onAppear { store.send(.onAppear) }
            .onDisappear(perform: { store.send(.onDisappear) })
        }
        .navigationBarTitleDisplayMode(.inline)
        .zashiBack()
        .screenTitle("Transactions".uppercased())
    }
}

// MARK: - Previews

#Preview {
    TransactionsManagerView(store: TransactionsManager.initial, tokenName: "ZEC")
}

// MARK: - Store

extension TransactionsManager {
    public static var initial = StoreOf<TransactionsManager>(
        initialState: .initial
    ) {
        TransactionsManager()
    }
}

// MARK: - Placeholders

extension TransactionsManager.State {
    public static let initial = TransactionsManager.State(transactionList: [])
}
