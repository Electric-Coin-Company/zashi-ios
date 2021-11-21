import SwiftUI
import ComposableArchitecture

struct Create: View {
    enum Route: Equatable {
        case showApprove(route: Approve.Route?)
    }

    let store: Store<SendState, SendAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Button(
                    action: { viewStore.send(.updateRoute(.showApprove(route: nil))) },
                    label: { Text("Go To Approve") }
                )
                .primaryButtonStyle
                .frame(height: 50)
                .padding()

                TextField(
                    "Amount",
                    text: viewStore
                        .bindingForTransaction
                        .amount
                        .compactMap(
                            extract: String.init,
                            embed: UInt.init
                        )
                )
                .padding()

                TextField(
                    "Address",
                    text: viewStore.bindingForTransaction.toAddress
                )

                Text("\(String(dumping: viewStore.transaction))")
                Text("\(String(dumping: viewStore.route))")

                Spacer()
            }
            .padding()
            .navigationTitle(Text("1. Create"))
            .navigationLinkEmpty(
                isActive: viewStore.routeBinding.map(
                    extract: { $0.map(/Route.showApprove) != nil },
                    embed: { $0 ? .showApprove(route: (/Route.showApprove).extract(from: viewStore.route)) : nil }
                ),
                destination: {
                    Approve(
                        transaction: viewStore.transaction,
                        route: viewStore.routeBinding.map(
                            extract: /Route.showApprove,
                            embed: Route.showApprove
                        )
                    )
                }
            )
        }
    }
}

// MARK: - Previews

struct Create_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Create(store: .demo)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#if DEBUG
extension SendStore {
    static var demo: SendStore {
        return SendStore(
            initialState: .init(
                transaction: .demo,
                route: nil
            ),
            reducer: .default,
            environment: ()
        )
    }
}
#endif
