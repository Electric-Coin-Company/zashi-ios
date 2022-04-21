import SwiftUI
import ComposableArchitecture

struct TransactionHistoryView: View {
    let store: Store<TransactionHistoryState, TransactionHistoryAction>

    var body: some View {
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear

        return WithViewStore(store) { viewStore in
            if viewStore.isScrollable {
                List {
                    transactionsList(with: viewStore)
                }
                .listStyle(.sidebar)
            } else {
                transactionsList(with: viewStore)
                    .padding(.leading, 32)
            }
        }
    }
}

extension TransactionHistoryView {
    func transactionsList(with viewStore: TransactionHistoryViewStore) -> some View {
        ForEach(viewStore.transactions) { transaction in
            WithStateBinding(binding: viewStore.bindingForSelectingTransaction(transaction)) { active in
                HStack {
                    Text("Show Transaction \(transaction.id)")
                        .navigationLink(
                            isActive: active,
                            destination: { TransactionDetailView(transaction: transaction) }
                        )
                        .foregroundColor(Asset.Colors.Text.body.color)
                        .listRowBackground(Color.clear)
                    
                    Spacer()
                }
            }
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
