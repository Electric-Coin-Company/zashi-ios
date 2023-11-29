//
//  BalanceBreakdownView.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 04.08.2022.
//

import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit
import Generated
import UIComponents
import Utils
import Models
import BalanceFormatter

public struct BalanceBreakdownView: View {
    let store: BalanceBreakdownStore
    let tokenName: String
    
    public init(store: BalanceBreakdownStore, tokenName: String) {
        self.store = store
        self.tokenName = tokenName
    }
    
    public var body: some View {
        ZStack {
            WithViewStore(store, observe: { $0 }) { viewStore in
                ScrollView {
                    BalanceWithIconView(balance: viewStore.shieldedBalance.data.total)
                        .padding(.top, 40)
                        .padding(.bottom, 5)
                    
                    AvailableBalanceView(
                        balance: viewStore.shieldedBalance.data.verified,
                        tokenName: tokenName
                    )
                    
                    Asset.Colors.primary.color
                        .frame(height: 1)
                        .padding(EdgeInsets(top: 30, leading: 30, bottom: 10, trailing: 30))
                    
                    balancesBlock(viewStore)
                    
                    transparentBlock(viewStore)
                    
                    progressBlock(viewStore)
                }
                .onAppear { viewStore.send(.onAppear) }
                .onDisappear { viewStore.send(.onDisappear) }
            }
        }
        .padding(.vertical, 1)
        .applyScreenBackground()
        .alert(store: store.scope(
            state: \.$alert,
            action: { .alert($0) }
        ))
    }
}

extension BalanceBreakdownView {
    @ViewBuilder func balancesBlock(_ viewStore: BalanceBreakdownViewStore) -> some View {
        VStack(spacing: 20) {
            HStack(spacing: 0) {
                Text(L10n.Balances.spendableBalance.uppercased())
                    .font(.custom(FontFamily.Inter.regular.name, size: 13))
                
                Spacer()
                
                ZatoshiRepresentationView(
                    balance: viewStore.shieldedBalance.data.verified,
                    fontName: FontFamily.Archivo.semiBold.name,
                    mostSignificantFontSize: 16,
                    leastSignificantFontSize: 8,
                    format: .expanded
                )
                
                Asset.Assets.shield.image
                    .resizable()
                    .frame(width: 11, height: 14)
                    .padding(.leading, 10)
            }
            
            HStack(spacing: 0) {
                Text(L10n.Balances.changePending.uppercased())
                    .font(.custom(FontFamily.Inter.regular.name, size: 13))
                
                Spacer()
                
                // TODO: [#932] pending balances
                // https://github.com/Electric-Coin-Company/zashi-ios/issues/932
                // zero for now until SDK support is implemented
                ZatoshiRepresentationView(
                    balance: viewStore.changePending,
                    fontName: FontFamily.Archivo.semiBold.name,
                    mostSignificantFontSize: 16,
                    leastSignificantFontSize: 8,
                    format: .expanded
                )
                .foregroundColor(Asset.Colors.shade47.color)
                
                if viewStore.changePending.amount > 0 {
                    progressViewLooping()
                        .padding(.leading, 10)
                }
            }
            
            HStack(spacing: 0) {
                Text(L10n.Balances.pendingTransactions.uppercased())
                    .font(.custom(FontFamily.Inter.regular.name, size: 13))
                
                Spacer()
                
                // TODO: [#932] pending balances
                // https://github.com/Electric-Coin-Company/zashi-ios/issues/932
                // zero for now until SDK support is implemented
                ZatoshiRepresentationView(
                    balance: viewStore.pendingTransactions,
                    fontName: FontFamily.Archivo.semiBold.name,
                    mostSignificantFontSize: 16,
                    leastSignificantFontSize: 8,
                    format: .expanded
                )
                .foregroundColor(Asset.Colors.shade47.color)

                if viewStore.pendingTransactions.amount > 0 {
                    progressViewLooping()
                        .padding(.leading, 10)
                }
            }
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 15)
    }
    
    @ViewBuilder func transparentBlock(_ viewStore: BalanceBreakdownViewStore) -> some View {
        VStack {
            HStack(spacing: 0) {
                Text(L10n.Balances.transparentBalance.uppercased())
                    .font(.custom(FontFamily.Inter.regular.name, size: 13))
                    .fixedSize()
                
                Button {
                    // TODO: [#933] open the hint box
                    // https://github.com/Electric-Coin-Company/zashi-ios/issues/933
                } label: {
                    Image(systemName: "questionmark.circle.fill")
                        .resizable()
                        .frame(width: 11, height: 11)
                        .foregroundColor(Asset.Colors.primary.color)
                        .padding(.bottom, 10)
                        .padding(.leading, -5)
                }
                .frame(width: 20, height: 20)
                
                Spacer()
                
                ZatoshiRepresentationView(
                    balance: viewStore.transparentBalance.data.verified,
                    fontName: FontFamily.Archivo.semiBold.name,
                    mostSignificantFontSize: 16,
                    leastSignificantFontSize: 8,
                    format: .expanded
                )
                .foregroundColor(Asset.Colors.shade47.color)
            }
            .padding(.bottom, 10)

            Button {
                viewStore.send(.shieldFunds)
            } label: {
                if viewStore.isShieldingFunds {
                    HStack(spacing: 10) {
                        Text(L10n.Balances.shieldingInProgress.uppercased())
                            .font(.custom(FontFamily.Inter.medium.name, size: 10))
                        
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Asset.Colors.primary.color))
                    }
                } else {
                    Text(L10n.Balances.shieldButtonTitle.uppercased())
                        .font(.custom(FontFamily.Inter.medium.name, size: 10))
                }
            }
            .zcashStyle(
                minWidth: nil,
                height: 38,
                shadowOffset: 6
            )
            .padding(.bottom, 15)
            .disabled(!viewStore.isShieldableBalanceAvailable || viewStore.isShieldingFunds)
            
            Text(L10n.Balances.fee(ZatoshiStringRepresentation.feeFormat))
                .font(.custom(FontFamily.Inter.semiBold.name, size: 11))
        }
        .frame(height: 166)
        .padding(.horizontal, 30)
        .background {
            Asset.Colors.shade92.color
        }
        .padding(.horizontal, 30)
        // TODO: [#933] implement the hint box
        // https://github.com/Electric-Coin-Company/zashi-ios/issues/933
//        .overlay(alignment: .top) {
//            Text("Shield these funds to add them to your available balance.")
//                .font(Font.custom("Inter", size: 11))
//                .frame(width: 292, height: 62)
//                .alignmentGuide(.bottom) { $0[.top] }
//                .tooltipShape()
//                .padding(.top, 40)
//        }
    }
    
    @ViewBuilder func progressBlock(_ viewStore: BalanceBreakdownViewStore) -> some View {
        VStack(spacing: 5) {
            HStack {
                Text(viewStore.syncStatusMessage)
                    .font(.custom(FontFamily.Inter.regular.name, size: 10))
                
                if viewStore.isSyncing {
                    progressViewLooping()
                }
            }
            .frame(height: 16)
            .padding(.bottom, 5)

            Text(String(format: "%0.1f%%", viewStore.syncingPercentage * 100))
                .font(.custom(FontFamily.Inter.black.name, size: 10))
                .foregroundColor(Asset.Colors.primary.color)

            ProgressView(value: viewStore.syncingPercentage, total: 1.0)
                .progressViewStyle(ZashiSyncingProgressStyle())
        }
        .padding(.top, 40)
    }
    
    @ViewBuilder func progressViewLooping() -> some View {
        ProgressView()
            .scaleEffect(0.7)
            .frame(width: 11, height: 14)
    }
}

// MARK: - Previews

#Preview {
    NavigationView {
        BalanceBreakdownView(
            store: BalanceBreakdownStore(
                initialState: BalanceBreakdownReducer.State(
                    autoShieldingThreshold: Zatoshi(1_000_000),
                    changePending: .zero,
                    isShieldingFunds: true,
                    pendingTransactions: .zero,
                    shieldedBalance: Balance(WalletBalance(verified: Zatoshi(25_234_778), total: Zatoshi(35_814_169))),
                    synchronizerStatusSnapshot: SyncStatusSnapshot(.syncing(0.41)),
                    syncStatusMessage: "Syncing",
                    transparentBalance: Balance(WalletBalance(verified: Zatoshi(25_234_778), total: Zatoshi(35_814_169)))
                )
            ) {
                BalanceBreakdownReducer(networkType: .testnet)
            },
            tokenName: "ZEC"
        )
    }
    .navigationViewStyle(.stack)
}
