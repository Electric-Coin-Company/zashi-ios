import SwiftUI
import ComposableArchitecture

struct TransactionSent: View {
    let viewStore: SendFlowViewStore

    var body: some View {
        VStack {
            Text("send.succeeded")
            
            Button(
                action: {
                    viewStore.send(.updateDestination(.done))
                },
                label: { Text("general.close") }
            )
            .activeButtonStyle
            .frame(height: 50)
            .padding()

            Text("send.amount".localized("\(viewStore.amount.decimalString())"))
            + Text("send.address".localized("\(viewStore.address)"))
            + Text("send.memo".localized("\(viewStore.memoState.text.data)"))

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
