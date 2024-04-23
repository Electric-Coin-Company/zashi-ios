//
//  TransactionRowView.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 21.06.2022.
//

import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit
import Models
import Generated
import UIComponents

public struct TransactionRowView: View {
    let store: StoreOf<TransactionList>
    let transaction: TransactionState
    let tokenName: String
    let isLatestTransaction: Bool

    public init(
        store: StoreOf<TransactionList>,
        transaction: TransactionState,
        tokenName: String,
        isLatestTransaction: Bool = false
    ) {
        self.store = store
        self.transaction = transaction
        self.tokenName = tokenName
        self.isLatestTransaction = isLatestTransaction
    }

    public var body: some View {
        WithPerceptionTracking {
            Button {
                store.send(.transactionExpandRequested(transaction.id), animation: .default)
            } label: {
                if transaction.isExpanded {
                    TransactionHeaderView(
                        store: store,
                        transaction: transaction,
                        isLatestTransaction: isLatestTransaction
                    )
                } else {
                    TransactionHeaderView(
                        store: store,
                        transaction: transaction,
                        isLatestTransaction: isLatestTransaction
                    )
                }
            }
            
            if transaction.isExpanded {
                Group {
                    if !transaction.isTransparentRecipient && !transaction.isShieldingTransaction {
                        MessageView(
                            store: store,
                            messages: transaction.textMemos,
                            isSpending: transaction.isSpending,
                            isFailed: transaction.status == .failed
                        )
                    }
                    
                    TransactionIdView(
                        store: store,
                        transaction: transaction
                    )

                    if transaction.isSpending || transaction.isShieldingTransaction {
                        TransactionFeeView(fee: transaction.fee ?? .zero)
                            .padding(.vertical, 10)
                    }
                    
                    Button {
                        store.send(.transactionCollapseRequested(transaction.id), animation: .default)
                    } label: {
                        CollapseTransactionView()
                            .padding(.vertical, 20)
                    }
                }
                .padding(.horizontal, 60)
            }
        }
    }
}

#Preview {
    List {
        TransactionRowView(
            store: .placeholder,
            transaction: .mockedFailed,
            tokenName: "ZEC"
        )
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets())

        TransactionRowView(
            store: .placeholder,
            transaction: .mockedShielded,
            tokenName: "ZEC"
        )
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets())

        TransactionRowView(
            store: .placeholder,
            transaction: .mockedShieldedExpanded,
            tokenName: "ZEC"
        )
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets())

        TransactionRowView(
            store: .placeholder,
            transaction: .mockedReceived,
            tokenName: "ZEC"
        )
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets())
        
        TransactionRowView(
            store: .placeholder,
            transaction: .mockedSent,
            tokenName: "ZEC"
        )
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets())
    }
    .listStyle(.plain)
}
