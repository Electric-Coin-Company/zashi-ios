//
//  PendingView.swift
//  Zashi
//
//  Created by Lukáš Korba on 12-09-2025.
//

import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit
import Lottie

import Generated
import UIComponents
import Utils
import AddressBook
import TransactionDetails

public struct PendingView: View {
    @Environment(\.colorScheme) var colorScheme
    
    private enum Constants {
        static let lottieNameLight = "sending"
        static let lottieNameDark = "sending-dark"
    }
    
    @Perception.Bindable var store: StoreOf<SendConfirmation>
    let tokenName: String
    
    public init(store: StoreOf<SendConfirmation>, tokenName: String) {
        self.store = store
        self.tokenName = tokenName
    }
    
    public var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                Spacer()
                
                LottieView(
                    animation:
                            .named(
                                colorScheme == .light ? Constants.lottieNameLight : Constants.lottieNameDark
                            )
                )
                .resizable()
                .looping()
                .frame(width: 170, height: 170)

                Text(store.pendingTitle)
                    .zFont(.semiBold, size: 28, style: Design.Text.primary)
                    .padding(.top, 16)

                Text(store.pendingInfo)
                    .zFont(size: 14, style: Design.Text.primary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(1.5)
                    .padding(.top, 8)
                    .screenHorizontalPadding()

                if store.txIdToExpand != nil {
                    ZashiButton(
                        L10n.Send.viewTransaction,
                        type: .tertiary,
                        infinityWidth: false
                    ) {
                        store.send(.viewTransactionTapped)
                    }
                    .padding(.top, 16)
                }

                Spacer()
                
                ZashiButton(
                    L10n.General.close,
                    type: store.type != .regular && store.txIdToExpand != nil ? .ghost : .primary
                ) {
                    store.send(.closeTapped)
                }
                .padding(.bottom, store.type != .regular && store.txIdToExpand != nil ? 12 : 24)

                if store.type != .regular && store.txIdToExpand != nil {
                    ZashiButton(L10n.SwapAndPay.checkStatus) {
                        store.send(.checkStatusTapped)
                    }
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationBarBackButtonHidden()
        .padding(.vertical, 1)
        .screenHorizontalPadding()
        .applyIndigoScreenBackground()
    }
}

#Preview {
    NavigationView {
        SuccessView(
            store: SendConfirmation.initial,
            tokenName: "ZEC"
        )
    }
}
