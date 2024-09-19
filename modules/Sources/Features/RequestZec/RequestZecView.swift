//
//  RequestZecView.swift
//  Zashi
//
//  Created by Lukáš Korba on 09-20-2024.
//

import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit

import Generated
import UIComponents
import Utils

public struct RequestZecView: View {
    @Perception.Bindable var store: StoreOf<RequestZec>
    
    @FocusState private var isMemoFocused

    public init(store: StoreOf<RequestZec>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                ScrollView {
                    Asset.Assets.Brandmarks.brandmarkMax.image
                        .resizable()
                        .frame(width: 64, height: 64)
                        .padding(.top, 40)
                    
                    PrivacyBadge(.max)
                        .padding(.top, 26)
                    
                    Text("Payment Request")
                        .zFont(.medium, size: 18, style: Design.Text.tertiary)
                        .padding(.top, 12)
                    
                    Group {
                        Text(store.requestedZec.decimalString())
                        + Text(" ZEC")
                            .foregroundColor(Design.Text.quaternary.color)
                    }
                    .zFont(.semiBold, size: 56, style: Design.Text.primary)
                    .minimumScaleFactor(0.1)
                    .lineLimit(1)
                    .padding(.top, 4)
                    
                    MessageEditorView(
                        store: store.memoStore(),
                        title: "",
                        placeholder: "What’s this for?"
                    )
                    .frame(minHeight: 155)
                    .frame(maxHeight: 300)
                    .focused($isMemoFocused)
                    .onAppear {
                        store.send(.onAppear)
                        isMemoFocused = true
                    }
                }

                ZashiButton("Request") {
                    store.send(.requestTapped)
                }
                .disabled(!store.memoState.isValid)
                .padding(.bottom, 24)
            }
            .zashiBack()
            .screenHorizontalPadding()
            .applyScreenBackground()
        }
    }
}

#Preview {
    NavigationView {
        RequestZecView(store: RequestZec.placeholder)
    }
}

// MARK: - Placeholders

extension RequestZec.State {
    public static let initial = RequestZec.State()
}

extension RequestZec {
    public static let placeholder = StoreOf<RequestZec>(
        initialState: .initial
    ) {
        RequestZec()
    }
}

// MARK: - Store

extension StoreOf<RequestZec> {
    func memoStore() -> StoreOf<MessageEditor> {
        self.scope(
            state: \.memoState,
            action: \.memo
        )
    }
}
