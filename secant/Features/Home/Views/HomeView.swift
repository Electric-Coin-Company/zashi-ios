import SwiftUI
import ComposableArchitecture

struct HomeView: View {
    let store: Store<HomeState, HomeAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Text("balance \(viewStore.balance)")
            }
        }
    }
}

// MARK: - Previews

extension HomeStore {
    static var placeholder: HomeStore {
        HomeStore(
            initialState: .placeholder,
            reducer: .default.debug(),
            environment: ()
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
