import SwiftUI
import ComposableArchitecture

struct Create: View {
    @Binding var transaction: Transaction
    @Binding var isComplete: Bool

    var body: some View {
        VStack {
            Button(
                action: { isComplete = true },
                label: { Text("Go To Approve") }
            )
            .primaryButtonStyle
            .frame(height: 50)
            .padding()

            TextField(
                "Amount",
                text: $transaction
                    .amount
                    .compactMap(
                        extract: String.init,
                        embed: UInt.init
                    )
            )
            .padding()

            TextField(
                "Address",
                text: $transaction.toAddress
            )

            Text("\(String(dumping: transaction))")
            Text("\(String(dumping: isComplete))")

            Spacer()
        }
        .padding()
        .navigationTitle(Text("1. Create"))
    }
}

// MARK: - Previews

struct Create_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StateContainer(initialState: (Transaction.placeholder, false)) {
                Create(
                    transaction: $0.0,
                    isComplete: $0.1
                )
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#if DEBUG
extension SendStore {
    static var placeholder: SendStore {
        return SendStore(
            initialState: .init(
                transaction: .placeholder,
                route: nil
            ),
            reducer: .default,
            environment: ()
        )
    }
}
#endif
