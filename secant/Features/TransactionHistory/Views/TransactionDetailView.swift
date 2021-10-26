import SwiftUI

struct TransactionDetailView: View {
    var transaction: Transaction
    var body: some View {
        Text(String(dumping: transaction))
            .padding()
            .navigationTitle("Transaction: \(transaction.id)")
    }
}

extension Transaction {
    static var demo: Self {
        .init(
            id: 2,
            amount: 123,
            memo: "defaultMemo",
            toAddress: "ToAddress",
            fromAddress: "FromAddress"
        )
    }
}

#if DEBUG
struct TransactionDetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TransactionDetailView(transaction: .demo)
        }
    }
}
#endif
