import SwiftUI
import ComposableArchitecture
import StoreKit
import Generated
import TransactionList
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

                TransactionListView(store: store.historyStore(), tokenName: tokenName)
            }
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
        VStack(spacing: 0) {
            Button {
                viewStore.send(.balanceBreakdown)
            } label: {
                BalanceWithIconView(balance: viewStore.shieldedBalance.data.total)
            }
            .padding(.top, 40)

            if viewStore.migratingDatabase {
                Text(L10n.Home.migratingDatabases)
                    .padding(.top, 10)
                    .padding(.bottom, 30)
            } else {
                AvailableBalanceView(
                    balance: viewStore.shieldedBalance.data.verified,
                    tokenName: tokenName
                )
                .accessDebugMenuWithHiddenGesture {
                    viewStore.send(.debugMenuStartup)
                }
                .padding(.top, 10)
                .padding(.bottom, 30)
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
