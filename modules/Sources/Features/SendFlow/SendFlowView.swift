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

public struct SendFlowView: View {
    let store: SendFlowStore
    let tokenName: String
    @FocusState private var isFocused: Bool
    
    public init(store: SendFlowStore, tokenName: String) {
        self.store = store
        self.tokenName = tokenName
    }
    
    public var body: some View {
        isFocused = true
        
        return WithViewStore(store) { viewStore in
            CreateTransaction(store: store, tokenName: tokenName)
            .onAppear { viewStore.send(.onAppear) }
            .onDisappear { viewStore.send(.onDisappear) }
            .sheet(
                isPresented: viewStore.bindingForMemo,
                onDismiss: {
                    viewStore.send(.updateDestination(nil))
                },
                content: {
                    VStack {
                        MultipleLineTextField<EmptyView>(
                            store: store.memoStore(),
                            title: L10n.Send.memoPlaceholder,
                            titleAccessoryView: { EmptyView() }(),
                            isFocused: _isFocused
                        )
                        .frame(height: 200)
                        .padding()
                        
                        Spacer()
                    }
                }
            )
            .applyScreenBackground()
            .navigationLinkEmpty(
                isActive: viewStore.bindingForInProgress,
                destination: { TransactionSendingView(viewStore: viewStore, tokenName: tokenName) }
            )
            .navigationLinkEmpty(
                isActive: viewStore.bindingForScanQR,
                destination: {
                    ScanView(store: store.scanStore())
                }
            )
        }
    }
}

// MARK: - Previews

struct SendFLowView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SendFlowView(
                store: .init(
                    initialState: .init(
                        addMemoState: true,
                        destination: nil,
                        memoState: .placeholder,
                        scanState: .placeholder,
                        transactionAddressInputState: .placeholder,
                        transactionAmountInputState: .placeholder
                    ),
                    reducer: SendFlowReducer(networkType: .testnet)
                ),
                tokenName: "ZEC"
            )
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
        }
    }
}
