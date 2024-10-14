//
//  TransactionIdView.swift
//
//
//  Created by Lukáš Korba on 05.11.2023.
//

import SwiftUI
import ComposableArchitecture
import Generated
import Models

struct TransactionIdView: View {
    let store: StoreOf<TransactionList>
    let transaction: TransactionState

    public init(store: StoreOf<TransactionList>, transaction: TransactionState) {
        self.store = store
        self.transaction = transaction
    }

    var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .leading, spacing: 0) {
                if !transaction.isIdExpanded {
                    HStack {
                        Text(L10n.TransactionList.transactionId)
                        
                        Spacer(minLength: 50)
                        
                        Button {
                            store.send(.transactionIdExpandRequested(transaction.id))
                        } label: {
                            Text(transaction.id)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
                    }
                    .padding(.vertical, 5)
                    .padding(.bottom, transaction.isSpending ? 0 : 10)
                }
                
                if transaction.isIdExpanded {
                    Text(L10n.TransactionList.transactionId)
                        .padding(.vertical, 5)
                    
                    Text(transaction.id)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                        .padding(.bottom, 10)
                    
                    TapToCopyTransactionDataView(store: store, data: transaction.id.redacted)
                        .padding(.bottom, 5)
                        .padding(.bottom, transaction.isSpending ? 0 : 10)
                }
            }
            .font(.custom(FontFamily.Inter.regular.name, size: 13))
            .foregroundColor(Asset.Colors.shade47.color)
        }
    }
}

#Preview {
    var transaction = TransactionState.placeholder()
    transaction.isIdExpanded = true
    
    return TransactionIdView(
        store: .placeholder,
        transaction: transaction
    )
}
