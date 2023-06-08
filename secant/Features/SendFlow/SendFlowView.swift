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

struct SendFlowView: View {
    let store: SendFlowStore
    @FocusState private var isFocused: Bool
    
    var body: some View {
        isFocused = true
        
        return WithViewStore(store) { viewStore in
            CreateTransaction(store: store)
            .onAppear { viewStore.send(.onAppear) }
            .onDisappear { viewStore.send(.onDisappear) }
            .sheet(
                isPresented: viewStore.bindingForMemo,
                onDismiss: {
                    viewStore.send(.updateDestination(nil))
                },
                content: {
                    VStack {
                        MultipleLineTextField(
                            store: store.memoStore(),
                            title: L10n.Send.memoPlaceholder,
                            titleAccessoryView: {},
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
                destination: { TransactionSendingView(viewStore: viewStore) }
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
                    reducer: SendFlowReducer()
                )
            )
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
        }
    }
}
