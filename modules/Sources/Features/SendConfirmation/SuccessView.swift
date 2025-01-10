//
//  SuccessView.swift
//  Zashi
//
//  Created by Lukáš Korba on 10-28-2024.
//

import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit

import Generated
import UIComponents
import Utils
import PartialProposalError

public struct SuccessView: View {
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

                store.successIlustration
                    .resizable()
                    .frame(width: 148, height: 148)

                Text(store.isShielding ? L10n.Send.successShielding : L10n.Send.success)
                    .zFont(.semiBold, size: 28, style: Design.Text.primary)
                    .padding(.top, 16)

                Text(store.isShielding ? L10n.Send.successShieldingInfo : L10n.Send.successInfo)
                    .zFont(size: 14, style: Design.Text.primary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(1.5)
                    .screenHorizontalPadding()

                if !store.isShielding {
                    Text(store.address.zip316)
                        .zFont(addressFont: true, size: 14, style: Design.Text.primary)
                        .padding(.top, 4)
                }

                ZashiButton(
                    L10n.Send.viewTransaction,
                    type: .tertiary,
                    infinityWidth: false
                ) {
                    store.send(.viewTransactionTapped)
                }
                .padding(.top, 16)

                Spacer()
                
                ZashiButton(L10n.General.close) {
                    store.send(.closeTapped)
                }
                .padding(.bottom, 24)
            }
        }
        .navigationBarBackButtonHidden()
        .padding(.vertical, 1)
        .screenHorizontalPadding()
        .applySuccessScreenBackground()
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
