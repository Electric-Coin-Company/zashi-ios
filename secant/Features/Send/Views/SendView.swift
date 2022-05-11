import SwiftUI
import ComposableArchitecture

struct SendView: View {
    let store: SendStore

    var body: some View {
        WithViewStore(store) { viewStore in
            CreateTransaction(store: store)
            .onAppear { viewStore.send(.onAppear) }
            .onDisappear { viewStore.send(.onDisappear) }
            .navigationLinkEmpty(
                isActive: viewStore.bindingForConfirmation,
                destination: {
                    TransactionConfirmation(viewStore: viewStore)
                }
            )
        }
    }
}

struct SendView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SendView(
                store: .init(
                    initialState: .init(
                        route: nil,
                        transaction: .placeholder,
                        transactionAddressInputState: .placeholder,
                        transactionAmountInputState: .placeholder
                    ),
                    reducer: .default,
                    environment: SendEnvironment(
                        mnemonicSeedPhraseProvider: .live,
                        scheduler: DispatchQueue.main.eraseToAnyScheduler(),
                        walletStorage: .live(),
                        wrappedDerivationTool: .live(),
                        wrappedSDKSynchronizer: LiveWrappedSDKSynchronizer()
                    )
                )
            )
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}
