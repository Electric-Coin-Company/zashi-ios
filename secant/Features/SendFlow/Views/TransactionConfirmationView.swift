import SwiftUI
import ComposableArchitecture

struct TransactionConfirmation: View {
    let store: SendFlowStore

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Text("Send \(viewStore.amount.decimalString()) ZEC to")
                    .padding()
                    .foregroundColor(Asset.Colors.Text.forDarkBackground.color)

                Text("\(viewStore.address)?")
                    .truncationMode(.middle)
                    .lineLimit(1)
                    .padding()
                    .foregroundColor(Asset.Colors.Text.forDarkBackground.color)

                HStack {
                    CheckCircle(viewStore: ViewStore(store.addMemoStore()))
                    Text("Includes memo")
                        .foregroundColor(Asset.Colors.Text.forDarkBackground.color)
                }

                Spacer()

                HoldToSendButton {
                    viewStore.send(.sendConfirmationPressed)
                }

                Spacer()
            }
            .applyDarkScreenBackground()
            .navigationLinkEmpty(
                isActive: viewStore.bindingForInProgress,
                destination: { TransactionSendingView(viewStore: viewStore) }
            )
        }
    }
}

// MARK: - Previews

struct Confirmation_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StateContainer(
                initialState: (false)
            ) { _ in
                TransactionConfirmation(store: .placeholder)
            }
        }
    }
}
