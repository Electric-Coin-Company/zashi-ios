import SwiftUI
import ComposableArchitecture
import StoreKit
import Generated
import TransactionList
import Settings
import UIComponents
import SyncProgress
import Utils
import Models
import WalletBalances
import Vendors
import KeystoneSDK
import URKit

public struct HomeView: View {
    let store: StoreOf<Home>
    let tokenName: String
    
    let encoder: UREncoder
    let cosmosSignRequest = CosmosSignRequest(
        requestId: "7AFD5E09-9267-43FB-A02E-08C4A09417EC",
        signData: "7B226163636F756E745F6E756D626572223A22323930353536222C22636861696E5F6964223A226F736D6F2D746573742D34222C22666565223A7B22616D6F756E74223A5B7B22616D6F756E74223A2231303032222C2264656E6F6D223A22756F736D6F227D5D2C22676173223A22313030313936227D2C226D656D6F223A22222C226D736773223A5B7B2274797065223A22636F736D6F732D73646B2F4D736753656E64222C2276616C7565223A7B22616D6F756E74223A5B7B22616D6F756E74223A223132303030303030222C2264656E6F6D223A22756F736D6F227D5D2C2266726F6D5F61646472657373223A226F736D6F31667334396A7867797A30306C78363436336534767A767838353667756C64756C6A7A6174366D222C22746F5F61646472657373223A226F736D6F31667334396A7867797A30306C78363436336534767A767838353667756C64756C6A7A6174366D227D7D5D2C2273657175656E6365223A2230227D",
        dataType: .amino,
        accounts: [
            CosmosSignRequest.Account(
                path: "m/44'/118'/0'/0/0",
                xfp: "f23f9fd2",
                address: "4c2a59190413dff36aba8e6ac130c7a691cfb79f"
            )
        ]
    )
    
    @Shared(.inMemory(.walletStatus)) public var walletStatus: WalletStatus = .none

    public init(store: StoreOf<Home>, tokenName: String) {
        self.store = store
        self.tokenName = tokenName
        
        let keystoneSDK = KeystoneSDK().cosmos;
        let qrCode = try! keystoneSDK.generateSignRequest(cosmosSignRequest: cosmosSignRequest);
        self.encoder = qrCode;
    }

    public var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                AnimatedQRCode(urEncoder: encoder)
                
                
                WalletBalancesView(
                    store: store.scope(
                        state: \.walletBalancesState,
                        action: \.walletBalances
                    ),
                    tokenName: tokenName,
                    couldBeHidden: true
                )
                .padding(.top, 1)

                if walletStatus == .restoring {
                    SyncProgressView(
                        store: store.scope(
                            state: \.syncProgressState,
                            action: \.syncProgress
                        )
                    )
                    .frame(height: 94)
                    .frame(maxWidth: .infinity)
                    .background(Asset.Colors.syncProgresBcg.color)
                    .padding(.top, 7)
                }
                
                TransactionListView(
                    store:
                        store.scope(
                            state: \.transactionListState,
                            action: \.transactionList
                        ),
                    tokenName: tokenName
                )
            }
            .walletStatusPanel()
            .applyScreenBackground()
            .onAppear {
                store.send(.onAppear)
            }
            .onChange(of: store.canRequestReview) { canRequestReview in
                if canRequestReview {
                    if let currentScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        SKStoreReviewController.requestReview(in: currentScene)
                    }
                    store.send(.reviewRequestFinished)
                }
            }
            .onDisappear { store.send(.onDisappear) }
            .alert(
                store:
                    store.scope(
                        state: \.$alert,
                        action: \.alert
                    )
            )
        }
    }
}

// MARK: - Previews

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView(
                store:
                    StoreOf<Home>(
                        initialState:
                                .init(
                                    scanState: .initial,
                                    syncProgressState: .init(
                                        lastKnownSyncPercentage: Float(0.43),
                                        synchronizerStatusSnapshot: SyncStatusSnapshot(.syncing(0.41)),
                                        syncStatusMessage: "Syncing"
                                    ),
                                    transactionListState: .placeholder,
                                    walletBalancesState: .initial,
                                    walletConfig: .initial
                                )
                    ) {
                        Home()
                    },
                tokenName: "ZEC"
            )
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Text("M")
            )
            .screenTitle("Title")
        }
    }
}

// MARK: Placeholders

extension Home.State {
    public static var initial: Self {
        .init(
            scanState: .initial,
            syncProgressState: .initial,
            transactionListState: .initial,
            walletBalancesState: .initial,
            walletConfig: .initial
        )
    }
}

extension Home {
    public static var placeholder: StoreOf<Home> {
        StoreOf<Home>(
            initialState: .initial
        ) {
            Home()
        }
    }

    public static var error: StoreOf<Home> {
        StoreOf<Home>(
            initialState: .init(
                scanState: .initial,
                syncProgressState: .initial,
                transactionListState: .initial,
                walletBalancesState: .initial,
                walletConfig: .initial
            )
        ) {
            Home()
        }
    }
}
