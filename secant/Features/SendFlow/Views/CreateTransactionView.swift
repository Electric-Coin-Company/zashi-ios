import SwiftUI
import ComposableArchitecture

struct CreateTransaction: View {
    let store: SendFlowStore

    var body: some View {
        UITextView.appearance().backgroundColor = .clear
        
        return WithViewStore(store) { viewStore in
            VStack {
                VStack(spacing: 0) {
                    Text("\(viewStore.shieldedBalance.data.total.decimalString()) ZEC Available")
                    Text("Aditional funds may be in transit")
                        .font(.system(size: 13))
                        .opacity(0.6)
                }
                .padding()

                TransactionAddressTextField(
                    store: store.scope(
                        state: \.transactionAddressInputState,
                        action: SendFlowReducer.Action.transactionAddressInput
                    )
                )
                .padding()

                TransactionAmountTextField(
                    store: store.scope(
                        state: \.transactionAmountInputState,
                        action: SendFlowReducer.Action.transactionAmountInput
                    )
                )
                .padding()

                MultipleLineTextField(
                    store: store.memoStore(),
                    title: "Write a private message here",
                    titleAccessoryView: {}
                )
                .frame(height: 200)
                .padding()
                
                Button(
                    action: { viewStore.send(.sendPressed) },
                    label: { Text("Send") }
                )
                .activeButtonStyle
                .frame(height: 50)
                .padding()

                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .padding()
            .applyScreenBackground()
        }
    }
}

// MARK: - Previews

struct Create_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StateContainer(
                initialState: ( false )
            ) { _ in
                CreateTransaction(store: .placeholder)
            }
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.light)
        }
    }
}
