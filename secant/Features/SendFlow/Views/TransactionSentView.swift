import SwiftUI
import ComposableArchitecture

struct TransactionSent: View {
    let viewStore: SendFlowViewStore

    var body: some View {
        VStack {
            Text("Sending transaction succeeded")
            
            Button(
                action: {
                    viewStore.send(.updateRoute(.done))
                },
                label: { Text("Close") }
            )
            .primaryButtonStyle
            .frame(height: 50)
            .padding()

            Text("amount: \(viewStore.amount.decimalString())")
            + Text(" address: \(viewStore.address)")
            + Text(" memo: \(viewStore.memo)")

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
