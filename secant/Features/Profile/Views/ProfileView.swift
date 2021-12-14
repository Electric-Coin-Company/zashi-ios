import ComposableArchitecture
import SwiftUI

struct ProfileView: View {
    let store: ProfileStore

    var body: some View {
        WithViewStore(store) { viewStore in
            List {
                Text("Go To Wallet Info")
                .navigationLink(
                    isActive: viewStore.bindingForWalletInfo,
                    destination: {
                        Text("Wallet")
                    }
                )

                Text("Go To Settings")
                .navigationLink(
                    isActive: viewStore.bindingForSettings,
                    destination: {
                        Text("Settings")
                    }
                )
            }
            .navigationTitle(Text("\(String(describing: Self.self))"))
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView(
                store: .init(
                    initialState: .init(
                        walletInfoState: .init(),
                        settingsState: .init()
                    ),
                    reducer: .default,
                    environment: .init()
                )
            )
        }
    }
}
