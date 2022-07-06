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
                    TransactionConfirmation(viewStore: viewStore)
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
                        route: nil,
                        transactionAddressInputState: .placeholder,
                        transactionAmountInputState: .placeholder
                    ),
                    reducer: .default,
                    environment: SendFlowEnvironment(
                        derivationTool: .live(),
                        mnemonic: .live,
                        numberFormatter: .live(),
                        SDKSynchronizer: LiveWrappedSDKSynchronizer(),
                        scheduler: DispatchQueue.main.eraseToAnyScheduler(),
                        walletStorage: .live()
                    )
                )
            )
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
        }
    }
}
