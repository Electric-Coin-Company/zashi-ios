//
//  SendConfirmationView.swift
//
//
//  Created by Lukáš Korba on 28.11.2023.
//

import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit

import Generated
import UIComponents
import Utils
import PartialProposalError
import Scan

public struct SendConfirmationView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @Perception.Bindable var store: StoreOf<SendConfirmation>
    let tokenName: String
    
    public init(store: StoreOf<SendConfirmation>, tokenName: String) {
        self.store = store
        self.tokenName = tokenName
    }
    
    public var body: some View {
        WithPerceptionTracking {
            VStack {
                ScrollView {
                    // Total Amount
                    VStack(spacing: 0) {
                        Text(L10n.Send.amountSummary)
                            .zFont(size: 14, style: Design.Text.primary)
                            .padding(.bottom, 2)
                        
                        BalanceWithIconView(balance: store.amount + store.feeRequired)
                        
                        Text(store.currencyAmount.data)
                            .zFont(.semiBold, size: 16, style: Design.Text.primary)
                            .padding(.top, 10)
                    }
                    .screenHorizontalPadding()
                    .padding(.top, 40)
                    .padding(.bottom, 20)

                    // Sending to
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(L10n.Send.toSummary)
                                .zFont(.medium, size: 14, style: Design.Text.tertiary)

                            if let alias = store.alias {
                                Text(alias)
                                    .zFont(.medium, size: 14, style: Design.Inputs.Filled.label)
                            }
                            
                            Text(store.address)
                                .zFont(addressFont: true, size: 12, style: Design.Text.primary)
                        }
                        
                        Spacer()
                    }
                    .screenHorizontalPadding()
                    .padding(.bottom, 20)

                    // Sending from
                    if store.walletAccounts.count > 1 {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(L10n.Accounts.sendingFrom)
                                    .zFont(.medium, size: 14, style: Design.Text.tertiary)
                                
                                if let selectedWalletAccount = store.selectedWalletAccount {
                                    HStack(spacing: 0) {
                                        selectedWalletAccount.vendor.icon()
                                            .resizable()
                                            .frame(width: 24, height: 24)
                                            .background {
                                                Circle()
                                                    .fill(Design.Surfaces.bgAlt.color(colorScheme))
                                                    .frame(width: 32, height: 32)
                                            }
                                        
                                        Text(selectedWalletAccount.vendor.name())
                                            .zFont(.semiBold, size: 16, style: Design.Text.primary)
                                            .padding(.leading, 16)
                                    }
                                }
                            }
                            
                            Spacer()
                        }
                        .screenHorizontalPadding()
                        .padding(.bottom, 20)
                    }

                    // Amount
                    HStack {
                        Text(L10n.Send.amount)
                            .zFont(.medium, size: 14, style: Design.Text.tertiary)
                        
                        Spacer()

                        ZatoshiRepresentationView(
                            balance: store.amount,
                            fontName: FontFamily.Inter.semiBold.name,
                            mostSignificantFontSize: 14,
                            leastSignificantFontSize: 7,
                            format: .expanded
                        )
                        .padding(.trailing, 4)
                    }
                    .screenHorizontalPadding()
                    .padding(.bottom, 20)
                    
                    // Fee
                    HStack {
                        Text(L10n.Send.feeSummary)
                            .zFont(.medium, size: 14, style: Design.Text.tertiary)
                        
                        Spacer()

                        ZatoshiRepresentationView(
                            balance: store.feeRequired,
                            fontName: FontFamily.Inter.semiBold.name,
                            mostSignificantFontSize: 14,
                            leastSignificantFontSize: 7,
                            format: .expanded
                        )
                        .padding(.trailing, 4)
                    }
                    .screenHorizontalPadding()
                    .padding(.bottom, 20)

                    // Memo
                    if !store.message.isEmpty {
                        VStack(alignment: .leading) {
                            Text(L10n.Send.message)
                                .zFont(.medium, size: 14, style: Design.Text.tertiary)

                            HStack {
                                Text(store.message)
                                    .zFont(.medium, size: 14, style: Design.Inputs.Filled.text)
                                
                                Spacer(minLength: 0)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Design.Inputs.Filled.bg.color(colorScheme))
                            }
                        }
                        .screenHorizontalPadding()
                        .padding(.bottom, 40)
                    }
                }
                .padding(.vertical, 1)
                .navigationLinkEmpty(
                    isActive: $store.partialProposalErrorViewBinding,
                    destination: {
                        PartialProposalErrorView(
                            store: store.scope(
                                state: \.partialProposalErrorState,
                                action: \.partialProposalError
                            )
                        )
                    }
                )
                .alert($store.scope(state: \.alert, action: \.alert))
                
                Spacer()
                
                if store.selectedWalletAccount?.vendor == .keystone {
                    ZashiButton(L10n.Keystone.confirm) {
                        store.send(.confirmWithKeystoneTapped)
                    }
                    .screenHorizontalPadding()
                    .padding(.top, 40)
                } else {
                    if store.isSending {
                        ZashiButton(
                            L10n.Send.sending,
                            accessoryView:
                                ProgressView()
                                .progressViewStyle(
                                    CircularProgressViewStyle(
                                        tint: Asset.Colors.secondary.color
                                    )
                                )
                        ) { }
                            .screenHorizontalPadding()
                            .padding(.top, 40)
                            .disabled(store.isSending)
                    } else {
                        ZashiButton(L10n.General.send) {
                            store.send(.sendPressed)
                        }
                        .screenHorizontalPadding()
                        .padding(.top, 40)
                    }
                }
                
                ZashiButton(L10n.Send.goBack, type: .tertiary) {
                    store.send(.goBackPressed)
                }
                .screenHorizontalPadding()
                .disabled(store.isSending)
                .padding(.top, 4)
                .padding(.bottom, 24)
            }
            .onAppear { store.send(.onAppear) }
            .screenTitle(
                store.selectedWalletAccount?.vendor == .keystone
                ? L10n.Send.review
                : L10n.Send.confirmationTitle
            )
            .navigationLinkEmpty(
                isActive: store.bindingFor(.sending),
                destination: {
                    SendingView(store: store, tokenName: tokenName)
                }
            )
            .navigationLinkEmpty(
                isActive: store.bindingForStack(.signWithKeystone),
                destination: {
                    SignWithKeystoneView(store: store, tokenName: tokenName)
                }
            )
        }
        .navigationBarBackButtonHidden()
        .padding(.vertical, 1)
        .applyScreenBackground()
    }
}

#Preview {
    NavigationView {
        SendConfirmationView(
            store: SendConfirmation.initial,
            tokenName: "ZEC"
        )
    }
}

// MARK: - ViewStore

extension StoreOf<SendConfirmation> {
    func bindingForStack(_ destination: SendConfirmation.State.StackDestination) -> Binding<Bool> {
        Binding<Bool>(
            get: {
                if let currentStackValue = self.stackDestination?.rawValue {
                    return currentStackValue >= destination.rawValue
                } else {
                    if destination.rawValue == 0 {
                        return false
                    } else if destination.rawValue <= self.stackDestinationBindingsAlive {
                        return true
                    } else {
                        return false
                    }
                }
            },
            set: { _ in
                if let currentStackValue = self.stackDestination?.rawValue, currentStackValue == destination.rawValue {
                    let popIndex = destination.rawValue - 1
                    if popIndex >= 0 {
                        let popDestination = SendConfirmation.State.StackDestination(rawValue: popIndex)
                        self.send(.updateStackDestination(popDestination))
                    } else {
                        self.send(.updateStackDestination(nil))
                    }
                }
            }
        )
    }
}

extension StoreOf<SendConfirmation> {
    func scanStore() -> StoreOf<Scan> {
        self.scope(
            state: \.scanState,
            action: \.scan
        )
    }
}

// MARK: - Store

extension SendConfirmation {
    public static var initial = StoreOf<SendConfirmation>(
        initialState: .initial
    ) {
        SendConfirmation()
    }
}

// MARK: - Placeholders

extension SendConfirmation.State {
    public static let initial = SendConfirmation.State(
        address: "",
        amount: .zero,
        feeRequired: .zero,
        message: "",
        partialProposalErrorState: .initial,
        proposal: nil
    )
}

// MARK: - ViewStore

extension StoreOf<SendConfirmation> {
    func bindingFor(_ destination: SendConfirmation.State.Destination) -> Binding<Bool> {
        Binding<Bool>(
            get: { self.destination == destination },
            set: { self.send(.updateDestination($0 ? destination : nil)) }
        )
    }
    
    func bindingForResult(_ result: SendConfirmation.State.Result) -> Binding<Bool> {
        Binding<Bool>(
            get: { self.result == result },
            set: { self.send(.updateResult($0 ? result : nil)) }
        )
    }
}
