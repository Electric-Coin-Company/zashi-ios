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
    @FocusState private var isMessageFocused

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
                                VStack(alignment: .leading) {
                                    TransactionAddressTextField(
                                        store: store.scope(
                                            state: \.transactionAddressInputState,
                                            action: SendFlowReducer.Action.transactionAddressInput
                                        )
                                    )
                                    .frame(height: 63)
                                    .focused($isAddressFocused)
                                    .submitLabel(.next)
                                    .onSubmit {
                                        isAmountFocused = true
                                    }
                                    
                                    if viewStore.isInvalidAddressFormat {
                                        Text(L10n.Send.Error.invalidAddress)
                                            .foregroundColor(Asset.Colors.error.color)
                                            .font(.custom(FontFamily.Inter.regular.name, size: 12))
                                    }
                                }
                                .padding(.bottom, 20)
                                
                                VStack(alignment: .leading) {
                                    TransactionAmountTextField(
                                        store: store.scope(
                                            state: \.transactionAmountInputState,
                                            action: SendFlowReducer.Action.transactionAmountInput
                                        ),
                                        tokenName: tokenName
                                    )
                                    .frame(height: 63)
                                    .focused($isAmountFocused)
                                    .submitLabel(viewStore.isMemoInputEnabled ? .next : .return)
                                    .onSubmit {
                                        if viewStore.isMemoInputEnabled {
                                            isMessageFocused = true
                                        }
                                    }
                                    
                                    if viewStore.isInvalidAmountFormat {
                                        Text(L10n.Send.Error.invalidAmount)
                                            .foregroundColor(Asset.Colors.error.color)
                                            .font(.custom(FontFamily.Inter.regular.name, size: 12))
                                    } else if viewStore.isInsufficientFunds {
                                        Text(L10n.Send.Error.insufficientFunds)
                                            .foregroundColor(Asset.Colors.error.color)
                                            .font(.custom(FontFamily.Inter.regular.name, size: 12))
                                    }
                                }
                                .padding(.bottom, 20)
                            }
                            
                            MessageEditor(store: store.memoStore())
                                .frame(height: 175)
                                .disabled(!viewStore.isMemoInputEnabled)
                                .focused($isMessageFocused)
                                .toolbar {
                                    ToolbarItemGroup(placement: .keyboard) {
                                        Spacer()
                                        
                                        Button(L10n.General.done.uppercased()) {
                                            isAmountFocused = false
                                            isMessageFocused = false
                                            isAddressFocused = false
                                        }
                                        .foregroundColor(Asset.Colors.primary.color)
                                        .font(.custom(FontFamily.Inter.regular.name, size: 14))
                                    }
                                }
                                .id(InputID.message)
                            
                            Button {
                                viewStore.send(.reviewPressed)
                            } label: {
                                Text(L10n.Send.review.uppercased())
                            }
                            .zcashStyle()
                            .disabled(!viewStore.isValidForm || viewStore.isSending)
                            .padding(.top, 40)
                            .padding(.horizontal, 30)
                            
                            Text(viewStore.feeFormat)
                                .font(.custom(FontFamily.Inter.semiBold.name, size: 11))
                                .padding(.vertical, 20)
                        }
                        .padding(.horizontal, 30)
                        .onChange(of: isMessageFocused) { update in
                            withAnimation {
                                if update {
                                    value.scrollTo(InputID.message, anchor: .center)
                                }
                            }
                        }
                    }
                    .onAppear { viewStore.send(.onAppear) }
                    .applyScreenBackground()
                    .navigationLinkEmpty(
                        isActive: viewStore.bindingForScanQR,
                        destination: {
                            ScanView(store: store.scanStore())
                        }
                    )
                    .navigationLinkEmpty(
                        isActive: viewStore.bindingForPartialProposalError,
                        destination: {
                            PartialProposalErrorView(store: store.partialProposalErrorStore())
                        }
                    )
                    .navigationLinkEmpty(
                        isActive: viewStore.bindingForSendConfirmation,
                        destination: {
                            SendFlowConfirmationView(store: store, tokenName: tokenName)
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
                    partialProposalErrorState: .initial,
                    scanState: .initial,
                    transactionAddressInputState: .initial,
                    transactionAmountInputState: .initial,
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
