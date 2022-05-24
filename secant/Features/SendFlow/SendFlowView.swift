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
                        transaction: .placeholder,
                        transactionAddressInputState: .placeholder,
                        transactionAmountInputState: .placeholder
                    ),
                    reducer: .default,
                    environment: SendFlowEnvironment(
                        mnemonic: .live,
                        scheduler: DispatchQueue.main.eraseToAnyScheduler(),
                        walletStorage: .live(),
                        derivationTool: .live(),
                        SDKSynchronizer: LiveWrappedSDKSynchronizer()
                    )
                )
            )
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}
