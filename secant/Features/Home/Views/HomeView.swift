import SwiftUI
import ComposableArchitecture

struct HomeView: View {
    let store: Store<HomeState, HomeAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .center, spacing: 30.0) {
                Text("totalBalance \(viewStore.totalBalance)")
                Text("verifiedBalance \(viewStore.verifiedBalance)")
                    .accessDebugMenuWithHiddenGesture {
                        viewStore.send(.debugMenuStartup)
                    }
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
