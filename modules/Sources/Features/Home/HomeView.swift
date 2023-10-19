import SwiftUI
import ComposableArchitecture
import StoreKit
import Generated
import WalletEventsFlow
import Settings
import UIComponents

public struct HomeView: View {
    let store: HomeStore
    let tokenName: String
    
    public init(store: HomeStore, tokenName: String) {
        self.store = store
        self.tokenName = tokenName
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                balance(viewStore)

                WalletEventsFlowView(store: store.historyStore(), tokenName: tokenName)
            }
            .padding()
            .applyScreenBackground()
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
            .alert(store: store.scope(
                state: \.$alert,
                action: { .alert($0) }
            ))
            .navigationLinkEmpty(
                isActive: viewStore.bindingForDestination(.notEnoughFreeDiskSpace),
                destination: { NotEnoughFreeSpaceView(viewStore: viewStore) }
            )
        }
    }
}

// MARK: - Buttons

extension HomeView {
    func balance(_ viewStore: HomeViewStore) -> some View {
        Group {
            Button {
                viewStore.send(.balanceBreakdown)
            } label: {
                BalanceTitle(balance: viewStore.shieldedBalance.data.total)
            }

            if viewStore.walletConfig.isEnabled(.showFiatConversion) {
                Text("$\(viewStore.totalCurrencyBalance.decimalZashiFormatted())")
                    .font(.custom(FontFamily.Inter.regular.name, size: 20))
            }
            
            if viewStore.migratingDatabase {
                Text(L10n.Home.migratingDatabases)
            } else {
                Text(L10n.Balance.available(viewStore.shieldedBalance.data.verified.decimalZashiFormatted(), tokenName))
                    .font(.custom(FontFamily.Inter.regular.name, size: 12))
                    .accessDebugMenuWithHiddenGesture {
                        viewStore.send(.debugMenuStartup)
                    }
            }
        }
        .foregroundColor(Asset.Colors.primary.color)
    }
}

// MARK: - Previews

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView(store: .placeholder, tokenName: "ZEC")
        }
    }
}
