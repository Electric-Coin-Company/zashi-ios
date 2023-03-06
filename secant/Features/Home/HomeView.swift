import SwiftUI
import ComposableArchitecture

struct HomeView: View {
    let store: Store<HomeReducer.State, HomeReducer.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                HStack {
                    Spacer()

                    settingsButton(viewStore)
                }
                
                balance(viewStore)

                Spacer()

                sendButton(viewStore)

                receiveButton(viewStore)
                
                Button {
                    viewStore.send(.updateDestination(.transactionHistory))
                } label: {
                    Text("home.transactionHistory")
                        .foregroundColor(Asset.Colors.Mfp.fontDark.color)
                }
            }
            .applyScreenBackground()
            .navigationTitle("home.title")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: { viewStore.send(.onAppear) })
            .onDisappear(perform: { viewStore.send(.onDisappear) })
            .alert(self.store.scope(state: \.alert), dismiss: .dismissAlert)
            .fullScreenCover(isPresented: viewStore.bindingForDestination(.balanceBreakdown)) {
                BalanceBreakdownView(store: store.balanceBreakdownStore())
            }
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
            Text("home.sendZec")
        })
        .activeButtonStyle
        .padding(.bottom, 30)
        .disabled(viewStore.isSendButtonDisabled)
        .opacity(viewStore.isSendButtonDisabled ? 0.5 : 1)
    }
    
    func receiveButton(_ viewStore: HomeViewStore) -> some View {
        Button(action: {
            viewStore.send(.updateDestination(.profile))
        }, label: {
            Text("home.receiveZec")
        })
        .activeButtonStyle
        .padding(.bottom, 30)
    }
    
    func balance(_ viewStore: HomeViewStore) -> some View {
        Group {
            Button {
                viewStore.send(.updateDestination(.balanceBreakdown))
            } label: {
                Text("balance".localized("\(viewStore.shieldedBalance.data.total.decimalString())"))
                    .font(.system(size: 32))
                    .fontWeight(.bold)
                    .accessDebugMenuWithHiddenGesture {
                        viewStore.send(.debugMenuStartup)
                    }
            }
            
            Text("\(viewStore.synchronizerStatusSnapshot.message)")
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
