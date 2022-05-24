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

                Text("Show me backup phrase")
                .navigationLink(
                    isActive: viewStore.bindingForPhraseDisplay,
                    destination: {
                        RecoveryPhraseDisplayView(
                            store: store.scope(
                                state: \.phraseDisplayState,
                                action: ProfileAction.phraseDisplay
                            )
                        )
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

// MARK: - Previews

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView(
                store: .init(
                    initialState: .init(
                        phraseDisplayState: .init(),
                        settingsState: .init(),
                        walletInfoState: .init()
                    ),
                    reducer: .default,
                    environment: .live
                )
            )
        }
    }
}
