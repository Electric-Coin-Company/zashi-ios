import SwiftUI
import ComposableArchitecture

struct SendView: View {
    let store: Store<SendState, SendAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            CreateTransaction(
                store: store.scope(
                    state: \.transactionInputState,
                    action: SendAction.transactionInput
                ),
                transaction: viewStore.bindingForTransaction,
                isComplete: viewStore.bindingForConfirmation,
                totalBalance: viewStore.bindingForBalance
            )
            .onAppear { viewStore.send(.onAppear) }
            .onDisappear { viewStore.send(.onDisappear) }
            .navigationLinkEmpty(
                isActive: viewStore.bindingForConfirmation,
                destination: {
                    TransactionConfirmation(viewStore: viewStore)
                        .navigationLinkEmpty(
                            isActive: viewStore.bindingForSuccess,
                            destination: { TransactionSent(viewStore: viewStore) }
                        )
                        .navigationLinkEmpty(
                            isActive: viewStore.bindingForFailure,
                            destination: { TransactionFailed(viewStore: viewStore) }
                        )
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
                        transactionInputState: .placeholer
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
