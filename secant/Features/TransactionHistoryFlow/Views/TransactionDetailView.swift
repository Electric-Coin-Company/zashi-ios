import SwiftUI

struct TransactionDetailView: View {
    var transaction: TransactionState
    var body: some View {
        Text(String(dumping: transaction))
            .padding()
            .navigationTitle("Transaction: \(transaction.id)")
    }
}

// MARK: - Previews

struct TransactionDetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TransactionDetailView(transaction: .placeholder)
        }
    }
}
