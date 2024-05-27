//
//  RequestPaymentConfirmationView.swift
//  Zashi
//
//  Created by Lukáš Korba on 05-27-2024.
//

import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit

import Generated
import UIComponents
import Utils
import PartialProposalError

public struct RequestPaymentConfirmationView: View {
    @Perception.Bindable var store: StoreOf<SendConfirmation>
    let tokenName: String
    
    public init(store: StoreOf<SendConfirmation>, tokenName: String) {
        self.store = store
        self.tokenName = tokenName
    }
    
    public var body: some View {
        ZStack {
            WithPerceptionTracking {
                ScrollView {
                    // who requested
                    Text(store.address)
                        .font(.custom(FontFamily.Inter.regular.name, size: 14))
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 35)
                        .padding(.top, 20)

                    HStack {
                        Text("Requests:")
                            .font(.custom(FontFamily.Inter.medium.name, size: 14))
                        Spacer()
                    }
                    .padding(.horizontal, 35)
                    .padding(.vertical, 10)

                    // how much
                    HStack {
                        BalanceWithIconView(balance: store.amount)
                        Spacer()
                    }
                    .padding(.horizontal, 35)
                    .padding(.bottom, 20)

                    // description
                    if !store.message.isEmpty {
                        HStack {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("For:")
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

                    // fee applied
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
                Text("ZASHI ME")
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
        RequestPaymentConfirmationView(
            store: SendConfirmation.initial,
            tokenName: "ZEC"
        )
    }
}
