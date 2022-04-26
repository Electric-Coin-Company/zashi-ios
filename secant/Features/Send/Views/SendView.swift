import SwiftUI
import ComposableArchitecture

struct Transaction: Identifiable, Equatable, Hashable {
    var id: Int
    var amount: UInt
    var memo: String
    var toAddress: String
    var fromAddress: String
}

extension Transaction {
    static var placeholder: Self {
        .init(
            id: 2,
            amount: 123,
            memo: "defaultMemo",
            toAddress: "ToAddress",
            fromAddress: "FromAddress"
        )
    }
}

struct SendView: View {
    enum Route: Equatable {
        case showApprove
        case showSent
        case done
    }

    let store: Store<SendState, SendAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            Create(
                transaction: viewStore.bindingForTransaction,
                isComplete: viewStore.bindingForApprove
            )
            .navigationLinkEmpty(
                isActive: viewStore.bindingForApprove,
                destination: {
                    Approve(
                        transaction: viewStore.transaction,
                        isComplete: viewStore.bindingForSent
                    )
                    .navigationLinkEmpty(
                        isActive: viewStore.bindingForSent,
                        destination: {
                            Sent(
                                transaction: viewStore.transaction,
                                isComplete: viewStore.bindingForDone
                            )
                        }
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
                        transaction: .placeholder,
                        route: nil
                    ),
                    reducer: .default,
                    environment: ()
                )
            )
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}
