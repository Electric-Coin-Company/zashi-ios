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
            TransactionHistoryView(store: .placeholder)
        }
    }
}
