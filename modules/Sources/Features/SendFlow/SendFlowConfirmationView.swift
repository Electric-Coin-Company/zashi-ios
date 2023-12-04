//
//  SendFlowConfirmationView.swift
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

public struct SendFlowConfirmationView: View {
    let store: SendFlowStore
    let tokenName: String
    
    public init(store: SendFlowStore, tokenName: String) {
        self.store = store
        self.tokenName = tokenName
    }
    
    public var body: some View {
        ZStack {
            WithViewStore(self.store, observe: { $0 }) { viewStore in
                ScrollView {
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(L10n.Send.amountSummary)
                                .font(.custom(FontFamily.Inter.regular.name, size: 14))
                            
                            BalanceWithIconView(balance: viewStore.amount)
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
                            Text(viewStore.address)
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
                                balance: Zatoshi(10_000),
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

                    if !viewStore.message.isEmpty {
                        HStack {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(L10n.Send.message)
                                    .font(.custom(FontFamily.Inter.regular.name, size: 14))
                                VStack(alignment: .leading, spacing: 0) {
                                    Color.clear.frame(height: 0)
                                    
                                    Text(viewStore.message)
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
                            viewStore.send(.sendPressed)
                        } label: {
                            if viewStore.isSending {
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
                            viewStore.send(.goBackPressed)
                        } label: {
                            Text(L10n.Send.goBack.uppercased())
                        }
                        .zcashStyle(
                            minWidth: nil,
                            height: 38,
                            shadowOffset: 6
                        )
                    }
                    .padding(.horizontal, 35)
                }
            }
            .zashiTitle {
                Text(L10n.Send.confirmationTitle.uppercased())
                    .font(.custom(FontFamily.Archivo.bold.name, size: 14))
            }
        }
        .navigationBarBackButtonHidden()
        .padding(.vertical, 1)
        .applyScreenBackground()
    }
}

#Preview {
    NavigationView {
        SendFlowConfirmationView(
            store: .init(
                initialState: .init(
                    addMemoState: true,
                    destination: nil,
                    memoState: MessageEditorReducer.State(
                        charLimit: 512,
                        text: "This is some message I want to see in the preview and long enough to have at least two lines".redacted
                    ),
                    scanState: .initial,
                    shieldedBalance: Balance(
                        WalletBalance(
                            verified: Zatoshi(4412323012_345),
                            total: Zatoshi(4412323012_345)
                        )
                    ),
                    transactionAddressInputState:
                        TransactionAddressTextFieldReducer.State(
                            textFieldState: 
                                TCATextFieldReducer.State(
                                validationType: nil,
                                text: "utest1zkkkjfxkamagznjr6ayemffj2d2gacdwpzcyw669pvg06xevzqslpmm27zjsctlkstl2vsw62xrjktmzqcu4yu9zdhdxqz3kafa4j2q85y6mv74rzjcgjg8c0ytrg7dwyzwtgnuc76h".redacted
                            )
                        ),
                    transactionAmountInputState: .initial
                )
            ) {
                SendFlowReducer(networkType: .testnet)
            },
            tokenName: "ZEC"
        )
    }
}
