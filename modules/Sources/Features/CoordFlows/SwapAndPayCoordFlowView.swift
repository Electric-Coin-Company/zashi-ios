//
//  SwapAndPayCoordFlowView.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-05-14.
//

import SwiftUI
import ComposableArchitecture

import UIComponents
import Generated

// Path
import AddressBook
import Scan
import SwapAndPayForm

public struct SwapAndPayCoordFlowView: View {
    @Environment(\.colorScheme) var colorScheme

    @Perception.Bindable var store: StoreOf<SwapAndPayCoordFlow>
    let tokenName: String

    public init(store: StoreOf<SwapAndPayCoordFlow>, tokenName: String) {
        self.store = store
        self.tokenName = tokenName
    }
    
    public var body: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                SwapAndPayForm(
                    store:
                        store.scope(
                            state: \.swapAndPayState,
                            action: \.swapAndPay
                        ),
                    tokenName: tokenName
                )
                .navigationBarHidden(true)
            } destination: { store in
                switch store.case {
                case let .addressBookChainToken(store):
                    AddressBookChainTokenView(store: store)
                case let .addressBookContact(store):
                    AddressBookContactView(store: store)
                case let .scan(store):
                    ScanView(store: store)
                }
            }
            .navigationBarHidden(!store.path.isEmpty)
        }
        .padding(.horizontal, 4)
        .applyScreenBackground()
        .zashiBack()
        .zashiTitle {
            Text(L10n.SendSelect.swapAndPay)
                .zFont(.semiBold, size: 16, style: Design.Text.primary)
                .fixedSize()
        }
    }
}

#Preview {
    NavigationView {
        SwapAndPayCoordFlowView(store: SwapAndPayCoordFlow.placeholder, tokenName: "ZEC")
    }
}

// MARK: - Placeholders

extension SwapAndPayCoordFlow.State {
    public static let initial = SwapAndPayCoordFlow.State()
}

extension SwapAndPayCoordFlow {
    public static let placeholder = StoreOf<SwapAndPayCoordFlow>(
        initialState: .initial
    ) {
        SwapAndPayCoordFlow()
    }
}
