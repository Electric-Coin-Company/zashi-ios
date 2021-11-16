import SwiftUI
import ComposableArchitecture

struct HomeView: View {
    let store: Store<HomeState, HomeAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Button(
                    action: { viewStore.toggleShowingHistory() },
                    label: { Text(viewStore.historyToggleString()) }
                )
                .primaryButtonStyle
                .frame(height: 50)

                Button(
                    action: { viewStore.toggleSelectedTransaction() },
                    label: { Text("Toggle Selected Transaction") }
                )
                .primaryButtonStyle
                .frame(height: 50)

                Spacer()

                HStack {
                    VStack(alignment: .leading) {
                        Text("Route: \(String(dumping: viewStore.route))")
                        Text("SelectedTransaction: \(String(dumping: viewStore.transactionHistoryState.route.map(/TransactionHistoryState.Route.showTransaction)))")
                    }
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer()
            }
            .padding(.horizontal, 30)
            .navigationBarTitle("Home", displayMode: .inline)
            .fullScreenCover(
                isPresented: viewStore.showHistoryBinding,
                content: {
                    NavigationView {
                        TransactionHistoryView(store: store.historyStore())
                            .toolbar {
                                ToolbarItem {
                                    Button("Done") { viewStore.send(.updateRoute(nil)) }
                                }
                            }
                    }
                }
            )
        }
    }
}

// MARK: - Previews

#if DEBUG
extension HomeStore {
    static var demo: HomeStore {
        HomeStore(
            initialState: HomeState(
                transactionHistoryState: .init(
                    transactions: .demo,
                    route: nil
                ),
                route: nil
            ),
            reducer: .default.debug(),
            environment: ()
        )
    }
}
#endif

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView(store: .demo)
        }
    }
}
