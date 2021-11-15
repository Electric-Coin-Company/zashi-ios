import SwiftUI

struct TransactionDetailView: View {
    var transaction: Transaction
    var body: some View {
        Text(String(dumping: transaction))
            .padding()
            .navigationTitle("Transaction: \(transaction.id)")
    }
}

struct TransactionDetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TransactionDetailView(transaction: .demo)
        }
    }
}

#if DEBUG
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
#endif
