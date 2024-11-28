//
//  AccountsSelectionView.swift
//  modules
//
//  Created by Lukáš Korba on 2024-11-27.
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents

public struct AccountsSelectionView: View {
    @Perception.Bindable var store: StoreOf<AddKeystoneHWWallet>
    
    public init(store: StoreOf<AddKeystoneHWWallet>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .leading, spacing: 0) {
                Asset.Assets.Partners.keystoneTitleLogo.image
                    .resizable()
                    .frame(width: 193, height: 32)
                    .padding(.top, 16)
                
                Text("Confirm Account to Access")
                    .zFont(.semiBold, size: 24, style: Design.Text.primary)
                    .padding(.top, 24)
                
                Text("Select the wallet you'd like to connect to proceed. Once connected, you’ll be able to wirelessly sign transactions with your hardware wallet.")
                    .zFont(size: 14, style: Design.Text.tertiary)
                    .lineSpacing(1.5)
                    .padding(.top, 8)
                
                accountView()
                    .padding(.top, 48)
                
                Spacer()

                ZashiButton(
                    "Unlock"
                ) {
                    store.send(.unlockTapped)
                }
                .padding(.bottom, 12)
                .disabled(!store.isKSAccountSelected)

                ZashiButton(
                    "Forget this device",
                    type: .ghost
                ) {
                    store.send(.forgetThisDeviceTapped)
                }
                .padding(.bottom, 24)
            }
            .screenHorizontalPadding()
            .zashiBackV2(background: false) {
                store.send(.forgetThisDeviceTapped)
            }
        }
        .applyScreenBackground()
    }
    
    @ViewBuilder func accountView() -> some View {
        WithPerceptionTracking {
            Button {
                store.send(.accountTapped)
            } label: {
                HStack(spacing: 0) {
                    Asset.Assets.Partners.keystoneLogo.image
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding(8)
                        .background {
                            Circle()
                                .fill(Design.Surfaces.brandFg.color)
                        }
                        .padding(.trailing, 8)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Keystone Wallet")
                            .zFont(.semiBold, size: 14, style: Design.Text.primary)
                        
                        Text(store.keystoneAddress)
                            .zFont(size: 12, style: Design.Text.tertiary)
                    }
                    
                    Spacer()
                    
                    ZashiToggle(
                        isOn: $store.isKSAccountSelected
                    )
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Design.Surfaces.strokeSecondary.color)
                }
            }
        }
    }
}