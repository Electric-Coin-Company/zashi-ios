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
            .disabled(store.transactionList.isEmpty)
            .applyScreenBackground()
            .listStyle(.plain)
            .onAppear { store.send(.onAppear) }
            .onDisappear(perform: { store.send(.onDisappear) })
        }
    }
}

// MARK: - Previews

#Preview {
    NavigationView {
        TransactionListView(store: .placeholder, tokenName: "ZEC")
            .preferredColorScheme(.light)
    }
}

// MARK: Placeholders

extension TransactionList.State {
    public static var placeholder: Self {
        .init(transactionList: .mocked)
    }

    public static var initial: Self {
        .init(transactionList: [])
    }
}

extension StoreOf<TransactionList> {
    public static var placeholder: Store<TransactionList.State, TransactionList.Action> {
        Store(
            initialState: .placeholder
        ) {
            TransactionList()
                .dependency(\.zcashSDKEnvironment, .testnet)
        }
    }
}

extension IdentifiedArrayOf where Element == TransactionState {
    public static var placeholder: IdentifiedArrayOf<TransactionState> {
        .init(
            uniqueElements: (0..<30).map {
                TransactionState(
                    fee: Zatoshi(10),
                    id: String($0),
                    status: .paid,
                    timestamp: 1234567,
                    zecAmount: Zatoshi(25)
                )
            }
        )
    }
    
    public static var mocked: IdentifiedArrayOf<TransactionState> {
        .init(
            uniqueElements: [
                TransactionState.mockedSent,
                TransactionState.mockedReceived
            ]
        )
    }
}
