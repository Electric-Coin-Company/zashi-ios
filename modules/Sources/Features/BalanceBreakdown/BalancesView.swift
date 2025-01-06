//
//  BalancesView.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 04.08.2022.
//

import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit
import Generated
import PartialProposalError
import UIComponents
import Utils
import Models
import BalanceFormatter
import SyncProgress
import WalletBalances
import Combine

public struct BalancesView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Perception.Bindable var store: StoreOf<Balances>
    let tokenName: String
    
    @Shared(.appStorage(.sensitiveContent)) var isSensitiveContentHidden = false
    @Shared(.inMemory(.walletStatus)) public var walletStatus: WalletStatus = .none

    public init(store: StoreOf<Balances>, tokenName: String) {
        self.store = store
        self.tokenName = tokenName
    }
    
    public var body: some View {
        ScrollView {
            WithPerceptionTracking {
                WalletBalancesView(
                    store: store.scope(
                        state: \.walletBalancesState,
                        action: \.walletBalances
                    ),
                    tokenName: tokenName,
                    underlinedAvailableBalance: false,
                    couldBeHidden: true
                )

                Asset.Colors.primary.color
                    .frame(height: 1)
                    .padding(EdgeInsets(top: 0, leading: 30, bottom: 10, trailing: 30))
                
                balancesBlock()
                
                transparentBlock()
                    .frame(minHeight: 166)
                    .padding(.horizontal, store.isHintBoxVisible ? 15 : 30)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Design.Surfaces.strokePrimary.color(colorScheme))
                    }
                    .padding(.horizontal, 30)

                if walletStatus == .restoring {
                    Text(L10n.Balances.restoringWalletWarning)
                        .zFont(.medium, size: 10, style: Design.Utility.ErrorRed._600)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 60)
                        .padding(.vertical, 20)
                }
                
                SyncProgressView(
                    store: store.scope(
                        state: \.syncProgressState,
                        action: \.syncProgress
                    )
                )
                .padding(.top, walletStatus == .restoring ? 0 : 40)
                .padding(.bottom, 25)
                .navigationLinkEmpty(
                    isActive: store.bindingFor(.partialProposalError),
                    destination: {
                        PartialProposalErrorView(store: store.partialProposalErrorStore())
                    }
                )
            }
            .walletStatusPanel()
        }
        .navigationBarTitleDisplayMode(.inline)
        .padding(.vertical, 1)
        .applyScreenBackground()
        .alert(
            store: store.scope(
                state: \.$alert,
                action: \.alert
            )
        )
        .onAppear { store.send(.onAppear) }
        .onDisappear { store.send(.onDisappear) }
    }
}

extension BalancesView {
    @ViewBuilder func balancesBlock() -> some View {
        VStack(spacing: 20) {
            HStack(spacing: 0) {
                Text(L10n.Balances.spendableBalance.uppercased())
                    .font(.custom(FontFamily.Inter.regular.name, size: 13))
                
                Spacer()
                
                ZatoshiRepresentationView(
                    balance: store.shieldedBalance,
                    fontName: FontFamily.Inter.semiBold.name,
                    mostSignificantFontSize: 16,
                    leastSignificantFontSize: 8,
                    format: .expanded,
                    couldBeHidden: true
                )
                
                Asset.Assets.shield.image
                    .zImage(width: 11, height: 14, color: Asset.Colors.primary.color)
                    .padding(.leading, 10)
            }
            
            HStack(spacing: 0) {
                Text(L10n.Balances.changePending.uppercased())
                    .font(.custom(FontFamily.Inter.regular.name, size: 13))
                
                Spacer()
                
                ZatoshiRepresentationView(
                    balance: store.changePending,
                    fontName: FontFamily.Inter.semiBold.name,
                    mostSignificantFontSize: 16,
                    leastSignificantFontSize: 8,
                    format: .expanded,
                    couldBeHidden: true
                )
                .foregroundColor(Asset.Colors.shade55.color)
                .padding(.trailing, store.changePending.amount > 0 ? 0 : 21)

                if store.changePending.amount > 0 {
                    progressViewLooping()
                        .padding(.leading, 10)
                }
            }
            
            HStack(spacing: 0) {
                Text(L10n.Balances.pendingTransactions.uppercased())
                    .font(.custom(FontFamily.Inter.regular.name, size: 13))
                
                Spacer()
                
                ZatoshiRepresentationView(
                    balance: store.pendingTransactions,
                    fontName: FontFamily.Inter.semiBold.name,
                    mostSignificantFontSize: 16,
                    leastSignificantFontSize: 8,
                    format: .expanded,
                    couldBeHidden: true
                )
                .foregroundColor(Asset.Colors.shade55.color)
                .padding(.trailing, store.pendingTransactions.amount > 0 ? 0 : 21)

                if store.pendingTransactions.amount > 0 {
                    progressViewLooping()
                        .padding(.leading, 10)
                }
            }
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 15)
    }
    
    @ViewBuilder func transparentBlock() -> some View {
        if store.isHintBoxVisible {
            transparentBlockHintBox()
                .frame(maxWidth: .infinity)
        } else {
            transparentBlockShielding()
        }
    }

    @ViewBuilder private func transparentBlockShielding() -> some View {
        VStack {
            HStack(spacing: 0) {
                Button {
                    store.send(.updateHintBoxVisibility(true))
                } label: {
                    HStack(spacing: 3) {
                        Text(L10n.Balances.transparentBalance.uppercased())
                            .font(.custom(FontFamily.Inter.regular.name, size: 13))
                            .fixedSize()

                        Image(systemName: "questionmark.circle.fill")
                            .resizable()
                            .frame(width: 11, height: 11)
                            .padding(.bottom, 10)
                    }
                    .foregroundColor(Asset.Colors.primary.color)
                }
                
                Spacer()
                
                ZatoshiRepresentationView(
                    balance: store.transparentBalance,
                    fontName: FontFamily.Inter.semiBold.name,
                    mostSignificantFontSize: 16,
                    leastSignificantFontSize: 8,
                    format: .expanded,
                    couldBeHidden: true
                )
                .foregroundColor(Asset.Colors.shade55.color)
            }
            .padding(.bottom, 10)

            if store.isShieldingFunds {
                ZashiButton(
                    L10n.Balances.shieldingInProgress,
                    accessoryView: ProgressView()
                ) { }
                .padding(.bottom, 15)
                .disabled(true)
            } else {
                ZashiButton(
                    L10n.Balances.shieldButtonTitle
                ) {
                    store.send(.shieldFunds)
                }
                .padding(.bottom, 15)
                .disabled(!store.isShieldableBalanceAvailable || store.isShieldingFunds || isSensitiveContentHidden)
            }

            Text("(\(ZatoshiStringRepresentation.feeFormat))")
                .font(.custom(FontFamily.Inter.semiBold.name, size: 11))
        }
    }

    @ViewBuilder private func transparentBlockHintBox() -> some View {
        VStack {
            Text(L10n.Balances.HintBox.message)
                .font(.custom(FontFamily.Inter.regular.name, size: 11))
                .multilineTextAlignment(.center)
                .foregroundColor(Asset.Colors.primary.color)
            
            Spacer()
            
            Button {
                store.send(.updateHintBoxVisibility(false))
            } label: {
                Text(L10n.Balances.HintBox.dismiss.uppercased())
                    .font(.custom(FontFamily.Inter.semiBold.name, size: 10))
                    .underline()
                    .foregroundColor(Asset.Colors.primary.color)
            }
        }
        .hintBoxShape()
        .padding(.vertical, 15)
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
        BalancesView(
            store: StoreOf<Balances>(
                initialState: Balances.State(
                    autoShieldingThreshold: Zatoshi(1_000_000),
                    changePending: Zatoshi(25_234_000),
                    isShieldingFunds: true,
                    isHintBoxVisible: true,
                    partialProposalErrorState: .initial,
                    pendingTransactions: Zatoshi(25_234_000),
                    syncProgressState: .init(
                        lastKnownSyncPercentage: 0.43,
                        synchronizerStatusSnapshot: SyncStatusSnapshot(.syncing(0.41)),
                        syncStatusMessage: "Syncing"
                    ),
                    walletBalancesState: .initial
                )
            ) {
                Balances()
            },
            tokenName: "ZEC"
        )
    }
    .navigationViewStyle(.stack)
}

// MARK: - Store

extension StoreOf<Balances> {
    func partialProposalErrorStore() -> StoreOf<PartialProposalError> {
        self.scope(
            state: \.partialProposalErrorState,
            action: \.partialProposalError
        )
    }
}

// MARK: - Placeholders

extension Balances.State {
    public static let placeholder = Balances.State(
        autoShieldingThreshold: .zero,
        changePending: .zero,
        isShieldingFunds: false,
        partialProposalErrorState: .initial,
        pendingTransactions: .zero,
        syncProgressState: .initial,
        walletBalancesState: .initial
    )
    
    public static let initial = Balances.State(
        autoShieldingThreshold: .zero,
        changePending: .zero,
        isShieldingFunds: false,
        partialProposalErrorState: .initial,
        pendingTransactions: .zero,
        syncProgressState: .initial,
        walletBalancesState: .initial
    )
}

extension StoreOf<Balances> {
    public static let placeholder = StoreOf<Balances>(
        initialState: .placeholder
    ) {
        Balances()
    }
}

// MARK: - Bondings

extension StoreOf<Balances> {
    func bindingFor(_ destination: Balances.State.Destination) -> Binding<Bool> {
        Binding<Bool>(
            get: { self.destination == destination },
            set: { self.send(.updateDestination($0 ? destination : nil)) }
        )
    }
}
