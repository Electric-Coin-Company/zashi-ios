//
//  SendingView.swift
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
import Lottie

public struct SendingView: View {
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
                LottieView(
                    animation:
                            .named(
                                colorScheme == .light ? Constants.lottieNameLight : Constants.lottieNameDark
                            )
                )
                .resizable()
                .looping()
                .frame(width: 110, height: 110)

                Text(store.isShielding ? L10n.Send.shielding : L10n.Send.sending)
                    .zFont(.semiBold, size: 28, style: Design.Text.primary)
                    .padding(.top, 16)

                Text(store.isShielding ? L10n.Send.shieldingInfo : L10n.Send.sendingInfo)
                    .zFont(size: 14, style: Design.Text.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)

                if !store.isShielding {
                    Text(store.address.zip316)
                        .zFont(addressFont: true, size: 14, style: Design.Text.primary)
                        .padding(.top, 4)
                }
            }
            .onAppear { store.send(.sendingScreenOnAppear) }
        }
        .navigationBarBackButtonHidden()
        .screenHorizontalPadding()
        .applyScreenBackground()
    }
}

#Preview {
    NavigationView {
        SendingView(
            store: SendConfirmation.initial,
            tokenName: "ZEC"
        )
    }
}
