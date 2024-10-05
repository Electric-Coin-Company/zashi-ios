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
            ScrollView {
                Group {
                    ZashiIcon()
                    
                    Text(L10n.DeleteWallet.title)
                        .font(.custom(FontFamily.Inter.semiBold.name, size: 25))
                        .padding(.bottom, 15)
                    
                    VStack(alignment: .leading) {
                        Text(L10n.DeleteWallet.message1)
                            .font(.custom(FontFamily.Inter.bold.name, size: 16))
                        
                        Text(L10n.DeleteWallet.message2)
                            .font(.custom(FontFamily.Inter.medium.name, size: 16))
                            .padding(.top, 20)
                    }
                    
                    HStack {
                        ZashiToggle(
                            isOn: $store.isAcknowledged,
                            label: L10n.DeleteWallet.iUnderstand
                        )

                        Spacer()
                    }
                    .padding(.top, 30)
                    
                    ZashiButton(L10n.DeleteWallet.actionButtonTitle) {
                        store.send(.deleteTapped)
                    }
                    .disabled(!store.isAcknowledged || store.isProcessing)
                    .padding(.vertical, 50)
                }
            }
            .padding(.vertical, 1)
            .zashiBack(store.isProcessing)
        }
        .navigationBarTitleDisplayMode(.inline)
        .screenHorizontalPadding()
        .applyScreenBackground()
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
