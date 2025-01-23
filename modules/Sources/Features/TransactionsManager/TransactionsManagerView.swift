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
    
    @Shared(.appStorage(.sensitiveContent)) var isSensitiveContentHidden = false

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
                    ForEach(0..<store.transactionPeriods.count) { sectionIndex in
                        WithPerceptionTracking {
                            Section {
                                ForEach(0..<store.transactionPeriodsList[sectionIndex].count) { transactionIndex in
                                    WithPerceptionTracking {
                                        Button {
                                            store.send(.transactionTapped(store.transactionPeriodsList[sectionIndex][transactionIndex].id))
                                        } label: {
                                            TransactionRowView(
                                                transaction: store.transactionPeriodsList[sectionIndex][transactionIndex],
                                                divider: store.latestTransactionId == store.transactionPeriodsList[sectionIndex][transactionIndex].id || transactionIndex == 0
                                            )
                                        }
                                        .listRowInsets(EdgeInsets())
                                    }
                                }
                                .listRowBackground(Asset.Colors.background.color)
                                .listRowSeparator(.hidden)
                            } header: {
                                Text(store.transactionPeriods[sectionIndex])
                                    .zFont(.medium, size: 16, style: Design.Text.tertiary)
                                    .screenHorizontalPadding()
                                    .listRowInsets(EdgeInsets())
                                    .listRowBackground(Asset.Colors.background.color)
                                    .listRowSeparator(.hidden)
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 1)
            .disabled(store.transactionList.isEmpty)
            .applyScreenBackground()
            .listStyle(.plain)
            .onAppear { store.send(.onAppear) }
            .onDisappear(perform: { store.send(.onDisappear) })
            .navigationBarItems(trailing: hideBalancesButton())
        }
        .navigationBarTitleDisplayMode(.inline)
        .zashiBack()
        .screenTitle("Transactions".uppercased())
    }
    
    @ViewBuilder func hideBalancesButton() -> some View {
        Button {
            $isSensitiveContentHidden.withLock { $0.toggle() }
        } label: {
            let image = isSensitiveContentHidden ? Asset.Assets.eyeOff.image : Asset.Assets.eyeOn.image
            image
                .zImage(size: 24, color: Asset.Colors.primary.color)
                .padding(8)
        }
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
