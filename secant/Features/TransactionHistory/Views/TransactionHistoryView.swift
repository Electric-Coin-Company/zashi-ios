import SwiftUI
import ComposableArchitecture

struct TransactionHistoryView: View {
    let store: Store<TransactionHistoryState, TransactionHistoryAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            List {
                ForEach(viewStore.transactions) { transaction in
                    WithStateBinding(binding: viewStore.bindingForSelectingTransaction(transaction)) {
                        Text("Show Transaction \(transaction.id)")
                            .navigationLink(
                                isActive: $0,
                                destination: { TransactionDetailView(transaction: transaction) }
                            )
                    }
                }
            }
            .navigationTitle(Text("Transactions"))
        }
    }
}

struct TransactionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TransactionHistoryView(store: .demo)
                .navigationBarTitleDisplayMode(.inline)
        }

        NavigationView {
            TransactionHistoryView(store: .demoWithSelectedTransaction)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#if DEBUG
extension TransactionHistoryStore {
    static var demo: Store<TransactionHistoryState, TransactionHistoryAction> {
        return Store(
            initialState: TransactionHistoryState(
                transactions: .demo,
                route: nil
            ),
            reducer: .default,
            environment: ()
        )
    }

    static var demoWithSelectedTransaction: Store<TransactionHistoryState, TransactionHistoryAction> {
        let transactions = IdentifiedArrayOf<Transaction>.demo
        return Store(
            initialState: TransactionHistoryState(
                transactions: transactions,
                route: .showTransaction(transactions[3])
            ),
            reducer: .default.debug(),
            environment: ()
        )
    }
}

extension IdentifiedArrayOf where Element == Transaction {
    static var demo: IdentifiedArrayOf<Transaction> {
        return .init(
            uniqueElements: (0..<10).map {
                Transaction(
                    id: $0,
                    amount: 25,
                    memo: "defaultMemo",
                    toAddress: "ToAddress",
                    fromAddress: "FromAddress"
                )
            }
        )
    }
}
#endif
