import SwiftUI
import ComposableArchitecture

struct TransactionFailed: View {
    let viewStore: SendFlowViewStore

    var body: some View {
        VStack {
            Text("Sending transaction failed")
            
            Button(
                action: {
                    viewStore.send(.updateDestination(.done))
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

// MARK: - Previews

struct TransactionFailed_Previews: PreviewProvider {
    static var previews: some View {
        TransactionFailed(viewStore: ViewStore(.placeholder))
    }
}
