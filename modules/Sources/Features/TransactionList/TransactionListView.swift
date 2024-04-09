import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents

public struct TransactionListView: View {
    let store: TransactionListStore
    let tokenName: String
    
    public init(store: TransactionListStore, tokenName: String) {
        self.store = store
        self.tokenName = tokenName
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List {
                if viewStore.transactionList.isEmpty {
                    Text(L10n.TransactionList.noTransactions)
                        .font(.custom(FontFamily.Inter.bold.name, size: 13))
                        .frame(maxWidth: .infinity)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Asset.Colors.shade97.color)
                        .listRowSeparator(.hidden)
                        .padding(.top, 30)
                } else {
                    ForEach(viewStore.transactionList) { transaction in
                        TransactionRowView(
                            viewStore: viewStore,
                            transaction: transaction,
                            tokenName: tokenName,
                            isLatestTransaction: viewStore.isLatestTransaction(id: transaction.id)
                        )
                        .listRowInsets(EdgeInsets())
                    }
                    .listRowBackground(Asset.Colors.shade97.color)
                    .listRowSeparator(.hidden)
                }
            }
            .disabled(viewStore.transactionList.isEmpty)
            .background(Asset.Colors.shade97.color)
            .listStyle(.plain)
            .onAppear { viewStore.send(.onAppear) }
            .onDisappear(perform: { viewStore.send(.onDisappear) })
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
