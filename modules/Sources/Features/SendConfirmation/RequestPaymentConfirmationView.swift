//
//  RequestPaymentConfirmationView.swift
//  Zashi
//
//  Created by Lukáš Korba on 05-27-2024.
//

import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit

import AddressBook
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
                    HStack {
                        VStack(alignment: .leading) {
                            if store.addressBookName != nil || store.addressBookNameStorage != nil {
                                Button {
                                    store.send(.swapTapped)
                                } label: {
                                    Image(systemName: "rectangle.2.swap")
                                        .renderingMode(.template)
                                        .resizable()
                                        .frame(width: 15, height: 15)
                                        .foregroundColor(Asset.Colors.primary.color)
                                }
                                .padding(5)
                            } else {
                                Button {
                                    store.send(.addressBookButtonTapped)
                                } label: {
                                    Image(systemName: "book")
                                        .renderingMode(.template)
                                        .resizable()
                                        .frame(width: 18, height: 15)
                                        .foregroundColor(Asset.Colors.primary.color)
                                }
                                .padding(5)
                                .navigationLinkEmpty(
                                    isActive: $store.addressBookViewBinding,
                                    destination: {
                                        AddressBookView(
                                            store: store.scope(
                                                state: \.addressBookState,
                                                action: \.addressBook
                                            )
                                        )
                                    }
                                )
                            }
                            
                            Text(store.addressBookName ?? store.address)
                                .font(.custom(FontFamily.Inter.bold.name, size: 16))
                        }
                        
                        Spacer()
                    }
                    .multilineTextAlignment(.leading)
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
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            BalanceWithIconView(balance: store.amount)
                            Spacer()
                        }
                        .padding(.bottom, store.isInsufficientFunds ? 0 : 20)
                        
                        if store.isInsufficientFunds {
                            Text(L10n.Send.Error.insufficientFunds)
                                .foregroundColor(Asset.Colors.error.color)
                                .font(.custom(FontFamily.Inter.regular.name, size: 12))
                                .padding(.bottom, 20)
                        }
                    }
                    .padding(.horizontal, 35)

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
                        .disabled(store.proposal == nil || store.isInsufficientFunds)

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
                .onAppear { store.send(.zashiMeOnAppear) }
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
