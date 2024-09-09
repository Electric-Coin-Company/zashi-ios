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

public struct SendConfirmationView: View {
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
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(L10n.Send.amountSummary)
                                .zFont(size: 14, style: Design.Text.primary)
                                .padding(.bottom, 2)
                            
                            BalanceWithIconView(balance: store.amount + store.feeRequired)
                            
                            Text(store.currencyAmount.data)
                                .zFont(.semiBold, size: 16, style: Design.Text.primary)
                                .padding(.top, 10)
                        }
                        
                        Spacer()
                    }
                    .screenHorizontalPadding()
                    .padding(.top, 40)
                    .padding(.bottom, 20)

                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(L10n.Send.toSummary)
                                .zFont(.medium, size: 14, style: Design.Text.tertiary)

                            if let alias = store.alias {
                                Text(alias)
                                    .zFont(.medium, size: 14, style: Design.Inputs.Filled.label)
                            }
                            
                            Text(store.address)
                                .zFont(size: 12, style: Design.Text.primary)
                        }
                        
                        Spacer()
                    }
                    .screenHorizontalPadding()
                    .padding(.bottom, 20)

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
                                    .fill(Design.Inputs.Filled.bg.color)
                            }
                        }
                        .screenHorizontalPadding()
                        .padding(.bottom, 40)
                    }
                }
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
                
                ZashiButton(L10n.Send.goBack, type: .tertiary) {
                    store.send(.goBackPressed)
                }
                .screenHorizontalPadding()
                .padding(.top, 4)
                .padding(.bottom, 24)
            }
            .onAppear { store.send(.onAppear) }
            .screenTitle(L10n.Send.confirmationTitle)
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
