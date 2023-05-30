import SwiftUI
import ComposableArchitecture
import Generated

struct TransactionSent: View {
    let viewStore: SendFlowViewStore

    var body: some View {
        VStack {
            Text(L10n.Send.succeeded)
            
            Button(
                action: {
                    viewStore.send(.updateDestination(.done))
                },
                label: { Text(L10n.General.close) }
            )
            .activeButtonStyle
            .frame(height: 50)
            .padding()

            Text(L10n.Send.amount(viewStore.amount.decimalString()))
            + Text(L10n.Send.address(viewStore.address))
            + Text(L10n.Send.memo(viewStore.memoState.text.data))

            Spacer()
        }
        .applyScreenBackground()
        .navigationBarHidden(true)
    }
}

// MARK: - Previews

struct TransactionSent_Previews: PreviewProvider {
    static var previews: some View {
        TransactionSent(viewStore: ViewStore(.placeholder))
    }
}
