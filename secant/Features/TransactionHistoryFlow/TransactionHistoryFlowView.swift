import SwiftUI
import ComposableArchitecture

struct TransactionHistoryFlowView: View {
    let store: TransactionHistoryFlowStore

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

extension TransactionHistoryFlowView {
    func transactionsList(with viewStore: TransactionHistoryFlowViewStore) -> some View {
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
                        + Text("\(transaction.zecAmount.asZecString()) ZEC")
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
    
    func header(with viewStore: TransactionHistoryFlowViewStore) -> some View {
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

// MARK: - Previews

struct TransactionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TransactionHistoryFlowView(store: .placeholder)
                .preferredColorScheme(.dark)
        }
    }
}
