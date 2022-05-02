import SwiftUI
import ComposableArchitecture

struct TransactionSent: View {
    let viewStore: SendViewStore

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

            Text("\(String(dumping: viewStore.transaction))")

            Spacer()
        }
        .applyScreenBackground()
        .navigationBarHidden(true)
    }
}

struct TransactionSent_Previews: PreviewProvider {
    static var previews: some View {
        TransactionSent(viewStore: ViewStore(.placeholder))
    }
}
