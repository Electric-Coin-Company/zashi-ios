import SwiftUI
import ComposableArchitecture

struct TransactionFailed: View {
    let viewStore: SendViewStore

    var body: some View {
        VStack {
            Text("Sending transaction failed")
            
            Button(
                action: {
                    viewStore.send(.updateRoute(.done))
                },
                label: { Text("Close") }
            )
            .primaryButtonStyle
            .frame(height: 50)
            .padding()

            Spacer()
        }
        .applyScreenBackground()
        .navigationBarHidden(true)
    }
}

struct TransactionFailed_Previews: PreviewProvider {
    static var previews: some View {
        TransactionFailed(viewStore: ViewStore(.placeholder))
    }
}
