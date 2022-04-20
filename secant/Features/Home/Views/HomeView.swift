import SwiftUI
import ComposableArchitecture

struct HomeView: View {
    let store: Store<HomeState, HomeAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            GeometryReader { proxy in
                ZStack {
                    VStack {
                        Text("totalBalance \(viewStore.totalBalance)")
                        Text("verifiedBalance \(viewStore.verifiedBalance)")
                            .accessDebugMenuWithHiddenGesture {
                                viewStore.send(.debugMenuStartup)
                            }

                        Spacer()
                    }
                    
                    Drawer(overlay: viewStore.bindingForDrawer(), maxHeight: proxy.size.height) {
                        VStack {
                            TransactionHistoryView(store: store.historyStore())
                                .padding(.top, 10)
                            
                            Spacer()
                        }
                        .applyScreenBackground()
                    }
                }
                .applyScreenBackground()
            }
            .onAppear(perform: { viewStore.send(.preparePublishers) })
        }
    }
}

// MARK: - Previews

extension HomeStore {
    static var placeholder: HomeStore {
        HomeStore(
            initialState: .placeholder,
            reducer: .default.debug(),
            environment: HomeEnvironment(
                combineSynchronizer: LiveCombineSynchronizer()
            )
        )
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView(store: .placeholder)
        }
    }
}
