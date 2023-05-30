import SwiftUI
import ComposableArchitecture
import StoreKit
import Generated

struct HomeView: View {
    let store: Store<HomeReducer.State, HomeReducer.Action>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                balance(viewStore)

                Spacer()

                sendButton(viewStore)

                receiveButton(viewStore)
                
                Button {
                    viewStore.send(.updateDestination(.transactionHistory))
                } label: {
                    Text(L10n.Home.transactionHistory)
                        .foregroundColor(Asset.Colors.Mfp.fontDark.color)
                }
            }
            .padding()
            .applyScreenBackground()
            .navigationTitle(L10n.Home.title)
            .navigationBarItems(trailing: settingsButton(viewStore))
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewStore.send(.onAppear)
            }
            .onChange(of: viewStore.canRequestReview) { canRequestReview in
                if canRequestReview {
                    if let currentScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        SKStoreReviewController.requestReview(in: currentScene)
                    }
                    viewStore.send(.reviewRequestFinished)
                }
            }
            .onDisappear { viewStore.send(.onDisappear) }
            .navigationLinkEmpty(
                isActive: viewStore.bindingForDestination(.balanceBreakdown),
                destination: { BalanceBreakdownView(store: store.balanceBreakdownStore()) }
            )
            .navigationLinkEmpty(
                isActive: viewStore.bindingForDestination(.notEnoughFreeDiskSpace),
                destination: { NotEnoughFreeSpaceView(viewStore: viewStore) }
            )
            .navigationLinkEmpty(
                isActive: viewStore.bindingForDestination(.transactionHistory),
                destination: { WalletEventsFlowView(store: store.historyStore()) }
            )
            .navigationLinkEmpty(
                isActive: viewStore.bindingForDestination(.send),
                destination: { SendFlowView(store: store.sendStore()) }
            )
            .navigationLinkEmpty(
                isActive: viewStore.bindingForDestination(.profile),
                destination: { ProfileView(store: store.profileStore()) }
            )
        }
    }
}

// MARK: - Buttons

extension HomeView {
    func settingsButton(_ viewStore: HomeViewStore) -> some View {
        Image(systemName: "gear")
            .resizable()
            .frame(width: 30, height: 30)
            .padding(15)
            .navigationLink(
                isActive: viewStore.bindingForDestination(.settings),
                destination: {
                    SettingsView(store: store.settingsStore())
                }
            )
            .tint(Asset.Colors.Mfp.primary.color)
    }

    func sendButton(_ viewStore: HomeViewStore) -> some View {
        Button(action: {
            viewStore.send(.updateDestination(.send))
        }, label: {
            Text(L10n.Home.sendZec(TargetConstants.tokenName))
        })
        .activeButtonStyle
        .padding(.bottom, 30)
        .disable(
            when: viewStore.isSendButtonDisabled,
            dimmingOpacity: 0.5
        )
    }
    
    func receiveButton(_ viewStore: HomeViewStore) -> some View {
        Button(action: {
            viewStore.send(.updateDestination(.profile))
        }, label: {
            Text(L10n.Home.receiveZec(TargetConstants.tokenName))
        })
        .activeButtonStyle
        .padding(.bottom, 30)
    }
    
    func balance(_ viewStore: HomeViewStore) -> some View {
        Group {
            Button {
                viewStore.send(.updateDestination(.balanceBreakdown))
            } label: {
                Text(L10n.balance(viewStore.shieldedBalance.data.verified.decimalString(), TargetConstants.tokenName))
                    .font(.system(size: 32))
                    .fontWeight(.bold)
            }

            if viewStore.walletConfig.isEnabled(.showFiatConversion) {
                Text("$\(viewStore.totalCurrencyBalance.decimalString())")
                    .font(.system(size: 20))
            }
            
            Text(viewStore.synchronizerStatusSnapshot.message)
                .accessDebugMenuWithHiddenGesture {
                    viewStore.send(.debugMenuStartup)
                }
        }
        .foregroundColor(Asset.Colors.Mfp.primary.color)
    }
}

// MARK: - Previews

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView(store: .placeholder)
        }
    }
}
