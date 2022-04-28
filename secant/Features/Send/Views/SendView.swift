import SwiftUI
import ComposableArchitecture

struct SendView: View {
    let store: Store<SendState, SendAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            Create(
                transaction: viewStore.bindingForTransaction,
                isComplete: viewStore.bindingForConfirmation
            )
            .navigationLinkEmpty(
                isActive: viewStore.bindingForConfirmation,
                destination: {
                    Confirmation(viewStore: viewStore)
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
                        transaction: .placeholder,
                        route: nil
                    ),
                    reducer: .default,
                    environment: SendEnvironment(
                        scheduler: DispatchQueue.main.eraseToAnyScheduler(),
                        wrappedSDKSynchronizer: LiveWrappedSDKSynchronizer()
                    )
                )
            )
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}
