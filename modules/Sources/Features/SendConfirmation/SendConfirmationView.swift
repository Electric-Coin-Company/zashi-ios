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
            ZStack {
                ScrollView {
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(L10n.Send.amountSummary)
                                .font(.custom(FontFamily.Inter.regular.name, size: 14))
                            
                            BalanceWithIconView(balance: store.amount)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 35)
                    .padding(.top, 40)
                    .padding(.bottom, 20)

                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(L10n.Send.toSummary)
                                .font(.custom(FontFamily.Inter.regular.name, size: 14))
                            Text(store.address)
                                .font(.custom(FontFamily.Inter.regular.name, size: 14))
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 35)
                    .padding(.bottom, 20)

                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(L10n.Send.feeSummary)
                                .font(.custom(FontFamily.Inter.regular.name, size: 14))
                            ZatoshiRepresentationView(
                                balance: store.feeRequired,
                                fontName: FontFamily.Archivo.semiBold.name,
                                mostSignificantFontSize: 16,
                                leastSignificantFontSize: 8,
                                format: .expanded
                            )
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 35)
                    .padding(.bottom, 20)

                    if !store.message.isEmpty {
                        HStack {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(L10n.Send.message)
                                    .font(.custom(FontFamily.Inter.regular.name, size: 14))
                                VStack(alignment: .leading, spacing: 0) {
                                    Color.clear.frame(height: 0)
                                    
                                    Text(store.message)
                                        .font(.custom(FontFamily.Inter.regular.name, size: 13))
                                        .foregroundColor(Asset.Colors.primary.color)
                                        .padding()
                                }
                                .messageShape()
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 35)
                        .padding(.bottom, 40)
                    }

                    HStack(spacing: 30) {
                        Button {
                            store.send(.sendPressed)
                        } label: {
                            if store.isSending {
                                HStack(spacing: 10) {
                                    Text(L10n.Send.sending.uppercased())
                                    
                                    ProgressView()
                                        .progressViewStyle(
                                            CircularProgressViewStyle(
                                                tint: Asset.Colors.secondary.color
                                            )
                                        )
                                }
                            } else {
                                Text(L10n.General.send.uppercased())
                            }
                        }
                        .zcashStyle(
                            minWidth: nil,
                            height: 38,
                            shadowOffset: 6
                        )

                        Button {
                            store.send(.goBackPressed)
                        } label: {
                            Text(L10n.Send.goBack.uppercased())
                        }
                        .zcashStyle(
                            minWidth: nil,
                            height: 38,
                            shadowOffset: 6
                        )
                    }
                    .disabled(store.isSending)
                    .padding(.horizontal, 35)
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
            }
            .zashiTitle {
                Text(L10n.Send.confirmationTitle.uppercased())
                    .font(.custom(FontFamily.Archivo.bold.name, size: 14))
            }
            .alert($store.scope(state: \.alert, action: \.alert))
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
