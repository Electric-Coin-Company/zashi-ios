import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents
import Models
import ZcashLightClientKit

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
                if store.transactionList.isEmpty {
                    Text(L10n.TransactionList.noTransactions)
                        .font(.custom(FontFamily.Inter.bold.name, size: 13))
                        .frame(maxWidth: .infinity)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Asset.Colors.shade97.color)
                        .listRowSeparator(.hidden)
                        .padding(.top, 30)
                } else {
                    ForEach(store.transactionList) { transaction in
                        WithPerceptionTracking {
                            TransactionRowView(
                                store: store,
                                transaction: transaction,
                                tokenName: tokenName,
                                isLatestTransaction: store.latestTransactionId == transaction.id
                            )
                            .listRowInsets(EdgeInsets())
                        }
                    }
                    .listRowBackground(Asset.Colors.shade97.color)
                    .listRowSeparator(.hidden)
                }
            }
            .disabled(store.transactionList.isEmpty)
            .background(Asset.Colors.shade97.color)
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
