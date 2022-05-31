import SwiftUI
import ComposableArchitecture

struct HomeView: View {
    let store: Store<HomeState, HomeAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            GeometryReader { proxy in
                ZStack {
                    scanButton(viewStore)
                    
                    profileButton(viewStore)
                    
                    sendButton(viewStore)
                    
                    VStack {
                        Text("\(viewStore.synchronizerStatus)")
                            .padding(.top, 60)

                        Text("balance \(viewStore.totalBalance.decimalString()) ZEC")
                            .accessDebugMenuWithHiddenGesture {
                                viewStore.send(.debugMenuStartup)
                            }
                            .padding(.top, 120)

                        Spacer()
                    }
                    
                    if proxy.size.height > 0 {
                        Drawer(overlay: viewStore.bindingForDrawer(), maxHeight: proxy.size.height) {
                            VStack {
                                TransactionHistoryFlowView(store: store.historyStore())
                                    .padding(.top, 10)
                                
                                Spacer()
                            }
                            .applyScreenBackground()
                        }
                    }
                }
                .applyScreenBackground()
                .navigationBarHidden(true)
                .onAppear(perform: { viewStore.send(.onAppear) })
                .onDisappear(perform: { viewStore.send(.onDisappear) })
            }
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
                        isActive: viewStore.bindingForRoute(.profile),
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
                    isActive: viewStore.bindingForRoute(.send),
                    destination: {
                        SendFlowView(store: store.sendStore())
                    }
                )

            Spacer()
        }
    }

    func scanButton(_ viewStore: HomeViewStore) -> some View {
        VStack {
            HStack {
                Image(Asset.Assets.Icons.qrCode.name)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .padding(.top, 7)
                    .padding(.leading, 22)
                    .navigationLink(
                        isActive: viewStore.bindingForRoute(.scan),
                        destination: {
                            ScanView(store: store.scanStore())
                        }
                    )
                
                Spacer()
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
