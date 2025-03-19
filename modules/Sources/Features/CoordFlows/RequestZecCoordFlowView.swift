//
//  RequestZecCoordFlowView.swift
//  Zashi
//
//  Created by Lukáš Korba on 2023-03-17.
//

import SwiftUI
import ComposableArchitecture

import UIComponents
import ZecKeyboard
import Generated

// Path
import RequestZec

public struct RequestZecCoordFlowView: View {
    @Environment(\.colorScheme) var colorScheme

    @Perception.Bindable var store: StoreOf<RequestZecCoordFlow>
    let tokenName: String

    public init(store: StoreOf<RequestZecCoordFlow>, tokenName: String) {
        self.store = store
        self.tokenName = tokenName
    }
    
    public var body: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                ZecKeyboardView(
                    store:
                        store.scope(
                            state: \.zecKeyboardState,
                            action: \.zecKeyboard
                        ),
                    tokenName: tokenName
                )
                .navigationBarHidden(true)
            } destination: { store in
                switch store.case {
                case let .requestZec(store):
                    RequestZecView(store: store, tokenName: tokenName)
                case let .requestZecSummary(store):
                    RequestZecSummaryView(store: store, tokenName: tokenName)
                }
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
        RequestZecCoordFlowView(store: RequestZecCoordFlow.placeholder, tokenName: "ZEC")
    }
}

// MARK: - Placeholders

extension RequestZecCoordFlow.State {
    public static let initial = RequestZecCoordFlow.State()
}

extension RequestZecCoordFlow {
    public static let placeholder = StoreOf<RequestZecCoordFlow>(
        initialState: .initial
    ) {
        RequestZecCoordFlow()
    }
}
