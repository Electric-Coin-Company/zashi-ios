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
    
    @State private var keyboardVisible: Bool = false

    @FocusState private var isMemoFocused
    
    let tokenName: String

    public init(store: StoreOf<RequestZec>, tokenName: String) {
        self.store = store
        self.tokenName = tokenName
    }
    
    public var body: some View {
        WithPerceptionTracking {
            ZStack {
                VStack(spacing: 0) {
                    ScrollView {
                        Asset.Assets.Brandmarks.brandmarkMax.image
                            .resizable()
                            .frame(width: 64, height: 64)
                            .padding(.top, 24)
                        
                        PrivacyBadge(store.maxPrivacy ? .max : .low)
                            .padding(.top, 26)
                        
                        Text(L10n.RequestZec.title)
                            .zFont(.medium, size: 18, style: Design.Text.tertiary)
                            .padding(.top, 12)
                        
                        Group {
                            Text(store.requestedZec.decimalString())
                            + Text(" \(tokenName)")
                                .foregroundColor(Design.Text.quaternary.color)
                        }
                        .zFont(.semiBold, size: 56, style: Design.Text.primary)
                        .minimumScaleFactor(0.1)
                        .lineLimit(1)
                        .padding(.top, 4)
                        
                        if store.maxPrivacy {
                            MessageEditorView(
                                store: store.memoStore(),
                                title: "",
                                placeholder: L10n.RequestZec.whatFor
                            )
                            .frame(minHeight: 155)
                            .frame(maxHeight: 300)
                            .focused($isMemoFocused)
                            .onAppear {
                                store.send(.onAppear)
                                isMemoFocused = true
                            }
                        }
                    }
                    .padding(.vertical, 1)
                    
                    ZashiButton(L10n.General.request) {
                        store.send(.requestTapped)
                    }
                    .disabled(!store.memoState.isValid)
                    .padding(.bottom, keyboardVisible ? 48 : 24)
                }
                .screenTitle(L10n.General.request)
                .zashiBack()
                .screenHorizontalPadding()
                .applyScreenBackground()
                .onAppear {
                    observeKeyboardNotifications()
                }
            }
            .overlay(
                VStack(spacing: 0) {
                    Spacer()

                    Asset.Colors.primary.color
                        .frame(height: 1)
                        .opacity(0.1)
                    
                    HStack(alignment: .center) {
                        Spacer()
                        
                        Button {
                            isMemoFocused = false
                        } label: {
                            Text(L10n.General.done.uppercased())
                                .zFont(.regular, size: 14, style: Design.Text.primary)
                        }
                        .padding(.bottom, 4)
                    }
                    .applyScreenBackground()
                    .padding(.horizontal, 20)
                    .frame(height: keyboardVisible ? 38 : 0)
                    .frame(maxWidth: .infinity)
                    .opacity(keyboardVisible ? 1 : 0)
                }
            )
        }
    }
    
    private func observeKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
            withAnimation {
                keyboardVisible = true
            }
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            withAnimation {
                keyboardVisible = false
            }
        }
    }
}

#Preview {
    NavigationView {
        RequestZecView(store: RequestZec.placeholder, tokenName: "ZEC")
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
