import SwiftUI
import ComposableArchitecture

struct HomeView: View {
    let store: Store<HomeReducer.State, HomeReducer.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                ZStack {
                    profileButton(viewStore)
                    
                    circularArea(viewStore)
                    
                    sendButton(viewStore)
                }
                
                Button {
                    viewStore.send(.updateDestination(.transactionHistory))
                } label: {
                    Text("See transaction history")
                }
            }
            .applyScreenBackground()
            .navigationBarHidden(true)
            .onAppear(perform: { viewStore.send(.onAppear) })
            .onDisappear(perform: { viewStore.send(.onDisappear) })
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
        }
    }
}

// MARK: - Buttons

extension HomeView {
    func profileButton(_ viewStore: HomeViewStore) -> some View {
        VStack {
            HStack {
                Spacer()
                
                Image(Asset.Assets.Icons.profile.name)
                    .resizable()
                    .frame(width: 60, height: 60)
                    .padding(.trailing, 15)
                    .navigationLink(
                        isActive: viewStore.bindingForDestination(.profile),
                        destination: {
                            ProfileView(store: store.profileStore())
                        }
                    )
            }
            
            Spacer()
        }
    }

    func sendButton(_ viewStore: HomeViewStore) -> some View {
        VStack {
            Spacer()
            
            Text("Send")
                .shadow(color: Asset.Colors.Buttons.buttonsTitleShadow.color, radius: 2, x: 0, y: 2)
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity
                )
                .foregroundColor(Asset.Colors.Text.activeButtonText.color)
                .background(Asset.Colors.Buttons.activeButton.color)
                .cornerRadius(12)
                .frame(height: 60)
                .padding(.horizontal, 50)
                .neumorphicButton()
                .navigationLink(
                    isActive: viewStore.bindingForDestination(.send),
                    destination: {
                        SendFlowView(store: store.sendStore())
                    }
                )

            Spacer()
        }
    }
    
    func circularArea(_ viewStore: HomeViewStore) -> some View {
        VStack {
            ZStack {
                CircularProgress(
                    outerCircleProgress: viewStore.isSyncing ? 0 : viewStore.synchronizerStatusSnapshot.progress,
                    innerCircleProgress: 1,
                    maxSegments: viewStore.requiredTransactionConfirmations,
                    innerCircleHidden: viewStore.isUpToDate
                )
                .padding(.top, 50)
                
                VStack {
                    Button {
                        viewStore.send(.updateDestination(.balanceBreakdown))
                    } label: {
                        Text("$\(viewStore.shieldedBalance.data.total.decimalString())")
                            .font(.custom(FontFamily.Zboto.regular.name, size: 40))
                            .foregroundColor(Asset.Colors.Text.balanceText.color)
                            .padding(.top, 80)
                    }

                    Text("$\(viewStore.totalCurrencyBalance.decimalString())")
                        .font(.custom(FontFamily.Rubik.regular.name, size: 13))
                        .opacity(0.6)
                        .padding(.bottom, 50)

                    Text("\(viewStore.synchronizerStatusSnapshot.message)")
                        .accessDebugMenuWithHiddenGesture {
                            viewStore.send(.debugMenuStartup)
                        }
                }
            }
            
            Spacer()
        }
    }
}

// MARK: - Previews

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView(store: .placeholder)
        }

        NavigationView {
            HomeView(store: .placeholder)
                .preferredColorScheme(.dark)
        }
    }
}
