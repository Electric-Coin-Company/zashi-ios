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
            VStack {
                Spacer()

                store.successIlustration
                    .resizable()
                    .frame(width: 148, height: 148)

                Text(L10n.Send.success)
                    .zFont(.semiBold, size: 28, style: Design.Text.primary)
                    .padding(.top, 16)

                Text(L10n.Send.successInfo)
                    .zFont(size: 14, style: Design.Text.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)

                Text(store.address.zip316)
                    .zFont(size: 14, style: Design.Text.primary)

                Button {
                } label: {
                    Text(L10n.Send.viewTransaction)
                        .zFont(.semiBold, size: 16, style: Design.Text.primary)
                        .padding()
                }
                .padding(.top, 16)
                .hidden()

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
