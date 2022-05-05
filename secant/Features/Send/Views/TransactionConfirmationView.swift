import SwiftUI
import ComposableArchitecture

struct TransactionConfirmation: View {
    let viewStore: SendViewStore

    var body: some View {
        VStack {
            Text("Send \(viewStore.transaction.amount.asZecString()) ZEC")
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
        .navigationLinkEmpty(
            isActive: viewStore.bindingForSuccess,
            destination: { TransactionSent(viewStore: viewStore) }
        )
        .navigationLinkEmpty(
            isActive: viewStore.bindingForFailure,
            destination: { TransactionFailed(viewStore: viewStore) }
        )
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
