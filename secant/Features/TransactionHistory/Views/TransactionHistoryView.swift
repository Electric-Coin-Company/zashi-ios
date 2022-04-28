import SwiftUI
import ComposableArchitecture

struct TransactionHistoryView: View {
    let store: Store<TransactionHistoryState, TransactionHistoryAction>

    var body: some View {
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear

        return WithViewStore(store) { viewStore in
            Group {
                header(with: viewStore)
                
                if viewStore.isScrollable {
                    List {
                        transactionsList(with: viewStore)
                    }
                    .listStyle(.sidebar)
                } else {
                    transactionsList(with: viewStore)
                        .padding(.horizontal, 32)
                }
            }
            .onAppear(perform: { viewStore.send(.onAppear) })
            .onDisappear(perform: { viewStore.send(.onDisappear) })
        }
    }
}

extension TransactionHistoryView {
    func transactionsList(with viewStore: TransactionHistoryViewStore) -> some View {
        ForEach(viewStore.transactions) { transaction in
            WithStateBinding(binding: viewStore.bindingForSelectingTransaction(transaction)) { active in
                VStack {
                    HStack {
                        Text(transaction.date.asHumanReadable())
                            .font(.system(size: 12))
                            .fontWeight(.thin)
                        
                        Spacer()
                        
                        Text(transaction.subtitle)
                            .font(.system(size: 12))
                            .fontWeight(.thin)
                            .foregroundColor(transaction.subtitle == "pending" ? .red : .green)
                    }
                    
                    HStack {
                        Text(transaction.status == .received ? "Recevied" : "Sent")
                        
                        Spacer()
                        
                        Text(transaction.status == .received ? "+" : "")
                        + Text("\(String(format: "%.7f", transaction.zecAmount.asHumanReadableZecBalance())) ZEC")
                    }
                }
                .navigationLink(
                    isActive: active,
                    destination: { TransactionDetailView(transaction: transaction) }
                )
                .foregroundColor(Asset.Colors.Text.body.color)
                .listRowBackground(Color.clear)
            }
        }
    }
    
    func header(with viewStore: TransactionHistoryViewStore) -> some View {
        HStack(spacing: 0) {
            VStack {
                Button("Latest") {
                    viewStore.send(.updateRoute(.latest))
                }
                
                Rectangle()
                    .frame(height: 1.5)
                    .foregroundColor(Asset.Colors.TextField.Underline.purple.color)
            }

            VStack {
                Button("All") {
                    viewStore.send(.updateRoute(.all))
                }

                Rectangle()
                    .frame(height: 1.5)
                    .foregroundColor(Asset.Colors.TextField.Underline.gray.color)
            }
        }
    }
}

struct TransactionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TransactionHistoryView(store: .placeholder)
                .preferredColorScheme(.dark)
        }
    }
}
