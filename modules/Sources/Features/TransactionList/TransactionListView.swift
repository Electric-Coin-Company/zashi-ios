import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents
import Models
import ZcashLightClientKit
import AddressBook

public struct TransactionListView: View {
    let store: StoreOf<TransactionList>
    let tokenName: String

    public init(store: StoreOf<TransactionList>, tokenName: String) {
        self.store = store
        self.tokenName = tokenName
    }
    
    public var body: some View {
        WithPerceptionTracking {
            List {
                if store.isInvalidated {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(0..<5) { _ in
                            NoTransactionPlaceholder(true)
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Asset.Colors.background.color)
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(store.transactionListHomePage) { transaction in
                        WithPerceptionTracking {
                            Button {
                                store.send(.transactionTapped(transaction.id))
                            } label: {
                                TransactionRowView(
                                    transaction: transaction,
                                    isUnread: TransactionList.isUnread(transaction),
                                    divider: store.latestTransactionId != transaction.id
                                )
                            }
                            .listRowInsets(EdgeInsets())
                        }
                    }
                    .listRowBackground(Asset.Colors.background.color)
                    .listRowSeparator(.hidden)
                }
            }
            .disabled(store.transactions.isEmpty)
            .applyScreenBackground()
            .listStyle(.plain)
            .onAppear { store.send(.onAppear) }
        }
    }
}

// MARK: - Previews

#Preview {
    NavigationView {
        TransactionListView(store: .initial, tokenName: "ZEC")
            .preferredColorScheme(.light)
    }
}

// MARK: Placeholders

extension TransactionList.State {
    public static var initial: Self {
        .init()
    }
}

extension StoreOf<TransactionList> {
    public static var initial: Store<TransactionList.State, TransactionList.Action> {
        Store(
            initialState: .initial
        ) {
            TransactionList()
        }
    }
}
