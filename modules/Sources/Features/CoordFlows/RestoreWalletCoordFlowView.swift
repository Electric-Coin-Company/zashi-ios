//
//  RestoreWalletCoordFlowView.swift
//  Zashi
//
//  Created by Lukáš Korba on 27-03-2025.
//

import SwiftUI
import ComposableArchitecture

import UIComponents
import Generated

// Path

public struct RestoreWalletCoordFlowView: View {
    @Environment(\.colorScheme) var colorScheme

    @Perception.Bindable var store: StoreOf<RestoreWalletCoordFlow>

    public init(store: StoreOf<RestoreWalletCoordFlow>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                Text("RestoreWalletCoordFlowView")
//                ZecKeyboardView(
//                    store:
//                        store.scope(
//                            state: \.zecKeyboardState,
//                            action: \.zecKeyboard
//                        ),
//                    tokenName: tokenName
//                )
//                .navigationBarHidden(true)
            } destination: { store in
//                switch store.case {
//                case let .requestZec(store):
//                    RequestZecView(store: store, tokenName: tokenName)
//                }
            }
            .navigationBarHidden(!store.path.isEmpty)
        }
        .padding(.horizontal, 4)
        .applyScreenBackground()
        .zashiBack()
        .screenTitle(L10n.General.request)
    }
}

#Preview {
    NavigationView {
        RestoreWalletCoordFlowView(store: RestoreWalletCoordFlow.placeholder)
    }
}

// MARK: - Placeholders

extension RestoreWalletCoordFlow.State {
    public static let initial = RestoreWalletCoordFlow.State()
}

extension RestoreWalletCoordFlow {
    public static let placeholder = StoreOf<RestoreWalletCoordFlow>(
        initialState: .initial
    ) {
        RestoreWalletCoordFlow()
    }
}
