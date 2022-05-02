import SwiftUI
import ComposableArchitecture

struct TransactionConfirmation: View {
    let viewStore: SendViewStore

    var body: some View {
        VStack {
            Text("Send \(String(format: "%.7f", Int64(viewStore.transaction.amount).asHumanReadableZecBalance())) ZEC")
                .padding()

            Text("To \(viewStore.transaction.toAddress)")
                .padding()

            Spacer()

            Button(
                action: { viewStore.send(.sendConfirmationPressed) },
                label: { Text("Confirm") }
            )
            .activeButtonStyle
            .frame(height: 50)
            .padding()

            Spacer()
        }
        .applyScreenBackground()
    }
}

struct Confirmation_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StateContainer(
                initialState: (
                    Transaction.placeholder,
                    false
                )
            ) { _ in
                TransactionConfirmation(
                    viewStore: ViewStore(.placeholder)
                )
            }
        }
        .preferredColorScheme(.dark)
    }
}
