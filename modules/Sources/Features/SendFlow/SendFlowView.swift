//
//  SendFlowView.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 04/25/2022.
//

import SwiftUI
import ComposableArchitecture
import Generated
import Scan
import UIComponents
import BalanceFormatter
import PartialProposalError
import WalletBalances

public struct SendFlowView: View {
    private enum InputID: Hashable {
        case message
    }
    
    let store: SendFlowStore
    let tokenName: String
    
    @FocusState private var isAddressFocused
    @FocusState private var isAmountFocused
    @FocusState private var isCurrencyFocused
    @FocusState private var isMemoFocused

    public init(store: SendFlowStore, tokenName: String) {
        self.store = store
        self.tokenName = tokenName
    }
    
    public var body: some View {
        ZStack {
            WithViewStore(store, observe: { $0 }) { viewStore in
                ScrollView {
                    ScrollViewReader { value in
                        VStack(alignment: .center) {
                            WalletBalancesView(
                                store: store.scope(
                                    state: \.walletBalancesState,
                                    action: SendFlowReducer.Action.walletBalances
                                ),
                                tokenName: tokenName,
                                couldBeHidden: true
                            )
                            
                            VStack(alignment: .leading) {
                                ZashiTextField(
                                    text: viewStore.bindingForAddress,
                                    placeholder: L10n.Field.TransactionAddress.validZcashAddress,
                                    title: L10n.Field.TransactionAddress.to,
                                    error: viewStore.isInvalidAddressFormat
                                    ? L10n.Send.Error.invalidAddress
                                    : nil,
                                    accessoryView:
                                        Button {
                                            viewStore.send(.updateDestination(.scanQR))
                                        } label: {
                                            Image(systemName: "qrcode")
                                                .resizable()
                                                .frame(width: 25, height: 25)
                                                .tint(Asset.Colors.primary.color)
                                        }
                                        .padding(.trailing, 8)
                                )
                                .keyboardType(.alphabet)
                                .focused($isAddressFocused)
                                .submitLabel(.next)
                                .onSubmit {
                                    isAmountFocused = true
                                }
                                .padding(.bottom, 20)
                                
                                VStack(alignment: .leading) {
                                    HStack(spacing: 4) {
                                        ZashiTextField(
                                            text: viewStore.bindingForZecAmount,
                                            placeholder: L10n.Field.TransactionAmount.zecAmount(tokenName),
                                            title: L10n.Field.TransactionAmount.amount,
                                            prefixView:
                                                ZcashSymbol()
                                                    .frame(width: 7, height: 12)
                                                    .padding(.leading, 10)
                                        )
                                        .keyboardType(.decimalPad)
                                        .focused($isAmountFocused)

                                        if viewStore.isCurrencyConversionEnabled {
                                            Asset.Assets.convertIcon.image
                                                .renderingMode(.template)
                                                .resizable()
                                                .frame(width: 10, height: 8)
                                                .foregroundColor(Asset.Colors.primary.color)
                                                .padding(.horizontal, 3)
                                                .padding(.top, 24)
                                            
                                            ZashiTextField(
                                                text: viewStore.bindingForCurrency,
                                                placeholder: L10n.Field.TransactionAmount.currencyAmount,
                                                prefixView:
                                                    Text(viewStore.currencySymbol)
                                                    .font(.custom(FontFamily.Archivo.bold.name, size: 14))
                                                    .padding(.leading, 10)
                                            )
                                            .keyboardType(.decimalPad)
                                            .focused($isCurrencyFocused)
                                            .padding(.top, 26)
                                            .disabled(viewStore.currencyConversion == nil)
                                            .opacity(viewStore.currencyConversion == nil ? 0.5 : 1.0)
                                        }
                                    }
                                    
                                    if viewStore.isInvalidAmountFormat {
                                        Text(L10n.Send.Error.invalidAmount)
                                            .foregroundColor(Design.Utility.ErrorRed._600.color)
                                            .font(.custom(FontFamily.Inter.medium.name, size: 12))
                                    } else if viewStore.isInsufficientFunds {
                                        Text(L10n.Send.Error.insufficientFunds)
                                            .foregroundColor(Design.Utility.ErrorRed._600.color)
                                            .font(.custom(FontFamily.Inter.medium.name, size: 12))
                                    }
                                }
                                .padding(.bottom, 20)
                            }
                            
                            MessageEditor(store: store.memoStore())
                                .frame(height: 190)
                                .disabled(!viewStore.isMemoInputEnabled)
                                .toolbar {
                                    ToolbarItemGroup(placement: .keyboard) {
                                        Spacer()
                                        
                                        Button(L10n.General.done.uppercased()) {
                                            isAmountFocused = false
                                            isAddressFocused = false
                                            isCurrencyFocused = false
                                            isMemoFocused = false
                                        }
                                        .foregroundColor(Asset.Colors.primary.color)
                                        .font(.custom(FontFamily.Inter.regular.name, size: 14))
                                    }
                                }
                                .id(InputID.message)
                                .focused($isMemoFocused)
                            
                            Button {
                                viewStore.send(.reviewPressed)
                            } label: {
                                Text(L10n.Send.review.uppercased())
                            }
                            .zcashStyle()
                            .disabled(!viewStore.isValidForm)
                            .padding(.top, 40)
                            .padding(.horizontal, 30)
                            
                            Text(viewStore.feeFormat)
                                .font(.custom(FontFamily.Inter.semiBold.name, size: 11))
                                .padding(.vertical, 20)
                        }
                        .padding(.horizontal, 30)
                    }
                    .onAppear { viewStore.send(.onAppear) }
                    .applyScreenBackground()
                    .navigationLinkEmpty(
                        isActive: viewStore.bindingForScanQR,
                        destination: {
                            ScanView(store: store.scanStore())
                        }
                    )
                }
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

// MARK: - Previews

#Preview {
    NavigationView {
        SendFlowView(
            store: .init(
                initialState: .init(
                    addMemoState: true,
                    destination: nil,
                    memoState: .initial,
                    scanState: .initial,
                    walletBalancesState: .initial
                )
            ) {
                SendFlowReducer()
            },
            tokenName: "ZEC"
        )
    }
    .navigationViewStyle(.stack)
}
