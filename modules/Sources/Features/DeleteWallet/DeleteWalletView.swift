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
                    .accentColor(.blue)

                Text(L10n.DeleteWallet.message2)
                    .zFont(size: 14, style: Design.Text.primary)
                    .padding(.top, 8)
                    .lineSpacing(1.5)

                Text(L10n.DeleteWallet.message3)
                    .zFont(size: 14, style: Design.Text.primary)
                    .padding(.top, 8)
                    .lineSpacing(1.5)

                Text(L10n.DeleteWallet.message4)
                    .zFont(size: 14, style: Design.Text.primary)
                    .padding(.top, 8)
                    .lineSpacing(1.5)

                Spacer()
                
                ZashiToggle(
                    isOn: $store.isAcknowledged,
                    label: L10n.DeleteWallet.iUnderstand
                )
                .padding(.bottom, 24)
                .padding(.leading, 1)
                
                if store.isProcessing {
                    ZashiButton(
                        L10n.DeleteWallet.actionButtonTitle,
                        type: .destructive1,
                        accessoryView: ProgressView()
                    ) { }
                    .disabled(true)
                    .padding(.bottom, 24)
                } else {
                    ZashiButton(
                        L10n.DeleteWallet.actionButtonTitle,
                        type: .destructive1
                    ) {
                        store.send(.deleteTapped)
                    }
                    .disabled(!store.isAcknowledged || store.isProcessing)
                    .padding(.bottom, 24)
                }
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
