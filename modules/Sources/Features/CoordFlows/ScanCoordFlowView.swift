//
//  ScanCoordFlowView.swift
//  Zashi
//
//  Created by Lukáš Korba on 2023-03-19.
//

import SwiftUI
import ComposableArchitecture

import UIComponents
import Generated

// Path
import Scan

public struct ScanCoordFlowView: View {
    @Environment(\.colorScheme) var colorScheme

    @Perception.Bindable var store: StoreOf<ScanCoordFlow>
    let tokenName: String

    public init(store: StoreOf<ScanCoordFlow>, tokenName: String) {
        self.store = store
        self.tokenName = tokenName
    }
    
    public var body: some View {
        WithPerceptionTracking {
            ScanView(
                store:
                    store.scope(
                        state: \.scanState,
                        action: \.scan
                    )
            )
            .onAppear() { store.send(.onAppear) }
            .navigationLinkEmpty(isActive: $store.sendCoordFlowBinding) {
                SendCoordFlowView(
                    store:
                        store.scope(
                            state: \.sendCoordFlowState,
                            action: \.sendCoordFlow),
                    tokenName: tokenName
                )
            }
        }
    }
}

#Preview {
    NavigationView {
        ScanCoordFlowView(store: ScanCoordFlow.placeholder, tokenName: "ZEC")
    }
}

// MARK: - Placeholders

extension ScanCoordFlow.State {
    public static let initial = ScanCoordFlow.State()
}

extension ScanCoordFlow {
    public static let placeholder = StoreOf<ScanCoordFlow>(
        initialState: .initial
    ) {
        ScanCoordFlow()
    }
}
