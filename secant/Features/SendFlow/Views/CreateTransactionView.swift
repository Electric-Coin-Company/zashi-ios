import SwiftUI
import ComposableArchitecture

struct CreateTransaction: View {
    let store: SendFlowStore

    var body: some View {
        UITextView.appearance().backgroundColor = .clear
        
        return WithViewStore(store) { viewStore in
            VStack {
                VStack(spacing: 0) {
                    Text(L10n.Balance.available(viewStore.shieldedBalance.data.total.decimalString()))
                        .font(.system(size: 32))
                        .fontWeight(.bold)
                    Text(L10n.Send.fundsInfo)
                        .font(.system(size: 16))
                }
                .foregroundColor(Asset.Colors.Mfp.fontDark.color)
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
                    title: L10n.Send.memoPlaceholder,
                    titleAccessoryView: {}
                )
                .frame(height: 200)
                .padding()
                
                Button(
                    action: { viewStore.send(.sendPressed) },
                    label: { Text(L10n.General.send) }
                )
                .activeButtonStyle

                Spacer()
            }
            .navigationTitle(L10n.Send.title)
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
