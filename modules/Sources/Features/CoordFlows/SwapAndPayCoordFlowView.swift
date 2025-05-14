//
//  SwapAndPayCoordFlowView.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-05-14.
//

import SwiftUI
import ComposableArchitecture

import UIComponents
import AddressBook
import Generated

// Path
import Scan

public struct SwapAndPayCoordFlowView: View {
    @Environment(\.colorScheme) var colorScheme

    @Perception.Bindable var store: StoreOf<SwapAndPayCoordFlow>

    public init(store: StoreOf<SwapAndPayCoordFlow>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                AddressBookView(
                    store:
                        store.scope(
                            state: \.addressBookState,
                            action: \.addressBook
                        )
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
//            .navigationBarItems(
//                trailing:
//                    Button {
//                        store.send(.helpSheetRequested)
//                    } label: {
//                        Asset.Assets.Icons.help.image
//                            .zImage(size: 24, style: Design.Text.primary)
//                            .padding(8)
//                    }
//            )
        }
        .padding(.horizontal, 4)
        .applyScreenBackground()
        .zashiBack()
        //.screenTitle(L10n.RecoveryPhraseDisplay.screenTitle.uppercased())
    }
}

#Preview {
    NavigationView {
        SwapAndPayCoordFlowView(store: SwapAndPayCoordFlow.placeholder)
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
