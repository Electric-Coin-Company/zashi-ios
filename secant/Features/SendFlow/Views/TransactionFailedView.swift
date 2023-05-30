import SwiftUI
import ComposableArchitecture
import Generated

struct TransactionFailed: View {
    let viewStore: SendFlowViewStore

    var body: some View {
        VStack {
            Text(L10n.Send.failed)
            
            Button(
                action: {
                    viewStore.send(.updateDestination(.done))
                },
                label: { Text(L10n.General.close) }
            )
            .activeButtonStyle
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
