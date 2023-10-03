import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents

public struct TransactionSent: View {
    let viewStore: SendFlowViewStore

    public init(viewStore: SendFlowViewStore) {
        self.viewStore = viewStore
    }

    public var body: some View {
        VStack {
            Text(L10n.Send.succeeded)
            
            Button(
                action: {
                    viewStore.send(.updateDestination(.done))
                },
                label: { Text(L10n.General.close.uppercased()) }
            )
            .zcashStyle()
            .frame(height: 50)
            .padding(.horizontal, 70)
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
