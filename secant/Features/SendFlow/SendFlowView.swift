//
//  SendFlowView.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 04/25/2022.
//

import SwiftUI
import ComposableArchitecture

struct SendFlowView: View {
    let store: SendFlowStore

    var body: some View {
        WithViewStore(store) { viewStore in
            CreateTransaction(store: store)
            .onAppear { viewStore.send(.onAppear) }
            .onDisappear { viewStore.send(.onDisappear) }
            .navigationLinkEmpty(
                isActive: viewStore.bindingForConfirmation,
                destination: {
                    TransactionConfirmation(store: store)
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
                        memoState: .placeholder,
                        destination: nil,
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
