//
//  DeleteWalletView.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 03-27-2024
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents

public struct DeleteWalletView: View {
    @Perception.Bindable var store: StoreOf<DeleteWallet>
    
    public init(store: StoreOf<DeleteWallet>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .leading, spacing: 0) {
                Text(L10n.DeleteWallet.title)
                    .zFont(.semiBold, size: 24, style: Design.Text.primary)
                    .padding(.top, 40)

                Text(L10n.DeleteWallet.message1)
                    .zFont(.semiBold, size: 16, style: Design.Text.primary)
                    .padding(.top, 12)

                Text(L10n.DeleteWallet.message2)
                    .zFont(size: 14, style: Design.Text.primary)
                    .padding(.top, 8)
                    .lineSpacing(1.5)

                Spacer()
                
                ZashiToggle(
                    isOn: $store.isAcknowledged,
                    label: L10n.DeleteWallet.iUnderstand
                )
                .padding(.bottom, 24)
                
                ZashiButton(
                    L10n.DeleteWallet.actionButtonTitle,
                    type: .destructive1
                ) {
                    store.send(.deleteTapped)
                }
                .disabled(!store.isAcknowledged || store.isProcessing)
                .padding(.bottom, 20)
            }
            .zashiBack(store.isProcessing)
        }
        .navigationBarTitleDisplayMode(.inline)
        .screenHorizontalPadding()
        .applyScreenBackground()
        .screenTitle(L10n.DeleteWallet.screenTitle.uppercased())
    }
}

// MARK: - Previews

#Preview {
    DeleteWalletView(store: DeleteWallet.demo)
}

// MARK: - Store

extension DeleteWallet {
    public static var demo = StoreOf<DeleteWallet>(
        initialState: .initial
    ) {
        DeleteWallet()
    }
}

// MARK: - Placeholders

extension DeleteWallet.State {
    public static let initial = DeleteWallet.State()
}
