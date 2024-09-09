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
    
    @Perception.Bindable var store: StoreOf<SendFlow>
    let tokenName: String
    
    @FocusState private var isAddressFocused
    @FocusState private var isAmountFocused
    @FocusState private var isCurrencyFocused
    @FocusState private var isMemoFocused

    public init(store: StoreOf<SendFlow>, tokenName: String) {
        self.store = store
        self.tokenName = tokenName
    }
    
    public var body: some View {
        ZStack {
            WithPerceptionTracking {
                ScrollView {
                    ScrollViewReader { value in
                        VStack(alignment: .center) {
                            WalletBalancesView(
                                store: store.scope(
                                    state: \.walletBalancesState,
                                    action: \.walletBalances
                                ),
                                tokenName: tokenName,
                                couldBeHidden: true
                            )
                            
                            VStack(alignment: .leading) {
                                ZashiTextField(
                                    text: store.bindingForAddress,
                                    placeholder: L10n.Field.TransactionAddress.validZcashAddress,
                                    title: L10n.Field.TransactionAddress.to,
                                    error: store.isInvalidAddressFormat
                                    ? L10n.Send.Error.invalidAddress
                                    : nil,
                                    accessoryView:
                                        Button {
                                            store.send(.updateDestination(.scanQR))
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
                                            text: store.bindingForZecAmount,
                                            placeholder: L10n.Field.TransactionAmount.zecAmount(tokenName),
                                            title: L10n.Field.TransactionAmount.amount,
                                            prefixView:
                                                ZcashSymbol()
                                                    .frame(width: 7, height: 12)
                                                    .padding(.leading, 10)
                                        )
                                        .keyboardType(.decimalPad)
                                        .focused($isAmountFocused)

                                        if store.isCurrencyConversionEnabled {
                                            Asset.Assets.convertIcon.image
                                                .renderingMode(.template)
                                                .resizable()
                                                .frame(width: 10, height: 8)
                                                .foregroundColor(Asset.Colors.primary.color)
                                                .padding(.horizontal, 3)
                                                .padding(.top, 24)
                                            
                                            ZashiTextField(
                                                text: store.bindingForCurrency,
                                                placeholder: L10n.Field.TransactionAmount.currencyAmount,
                                                prefixView:
                                                    Text(store.currencySymbol)
                                                    .font(.custom(FontFamily.Archivo.bold.name, size: 14))
                                                    .padding(.leading, 10)
                                            )
                                            .keyboardType(.decimalPad)
                                            .focused($isCurrencyFocused)
                                            .padding(.top, 26)
                                            .disabled(store.currencyConversion == nil)
                                            .opacity(store.currencyConversion == nil ? 0.5 : 1.0)
                                        }
                                    }
                                    
                                    if store.isInvalidAmountFormat {
                                        Text(L10n.Send.Error.invalidAmount)
                                            .foregroundColor(Design.Utility.ErrorRed._600.color)
                                            .font(.custom(FontFamily.Inter.medium.name, size: 12))
                                    } else if store.isInsufficientFunds {
                                        Text(L10n.Send.Error.insufficientFunds)
                                            .foregroundColor(Design.Utility.ErrorRed._600.color)
                                            .font(.custom(FontFamily.Inter.medium.name, size: 12))
                                    }
                                }
                                .padding(.bottom, 20)
                            }
                            
                            MessageEditorView(store: store.memoStore())
                                .frame(height: 190)
                                .disabled(!store.isMemoInputEnabled)
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
                                store.send(.reviewPressed)
                            } label: {
                                Text(L10n.Send.review.uppercased())
                            }
                            .zcashStyle()
                            .disabled(!store.isValidForm)
                            .padding(.top, 40)
                            .padding(.horizontal, 30)
                            
                            Text(store.feeFormat)
                                .font(.custom(FontFamily.Inter.semiBold.name, size: 11))
                                .padding(.vertical, 20)
                        }
                        .padding(.horizontal, 30)
                    }
                    .onAppear { store.send(.onAppear) }
                    .applyScreenBackground()
                    .navigationLinkEmpty(
                        isActive: store.bindingFor(.scanQR),
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
            action: \.alert
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
                SendFlow()
            },
            tokenName: "ZEC"
        )
    }
    .navigationViewStyle(.stack)
}

// MARK: - Store

extension StoreOf<SendFlow> {
    func memoStore() -> StoreOf<MessageEditor> {
        self.scope(
            state: \.memoState,
            action: \.memo
        )
    }
    
    func scanStore() -> StoreOf<Scan> {
        self.scope(
            state: \.scanState,
            action: \.scan
        )
    }
}

// MARK: - ViewStore

extension StoreOf<SendFlow> {
    func bindingFor(_ destination: SendFlow.State.Destination) -> Binding<Bool> {
        Binding<Bool>(
            get: { self.destination == destination },
            set: { self.send(.updateDestination($0 ? destination : nil)) }
        )
    }

    var bindingForAddress: Binding<String> {
        Binding(
            get: { self.address.data },
            set: { self.send(.addressUpdated($0.redacted)) }
        )
    }

    var bindingForCurrency: Binding<String> {
        Binding(
            get: { self.currencyText.data },
            set: { self.send(.currencyUpdated($0.redacted)) }
        )
    }
    
    var bindingForZecAmount: Binding<String> {
        Binding(
            get: { self.zecAmountText.data },
            set: { self.send(.zecAmountUpdated($0.redacted)) }
        )
    }
}

// MARK: Placeholders

extension SendFlow.State {
    public static var initial: Self {
        .init(
            addMemoState: true,
            destination: nil,
            memoState: .initial,
            scanState: .initial,
            walletBalancesState: .initial
        )
    }
}

// #if DEBUG // FIX: Issue #306 - Release build is broken
extension StoreOf<SendFlow> {
    public static var placeholder: StoreOf<SendFlow> {
        StoreOf<SendFlow>(
            initialState: .initial
        ) {
            SendFlow()
        }
    }
}
// #endif
