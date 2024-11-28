//
//  AddKeystoneHWWalletView.swift
//  Zashi
//
//  Created by Lukáš Korba on 2024-11-26.
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents
import Scan

public struct AddKeystoneHWWalletView: View {
    @Perception.Bindable var store: StoreOf<AddKeystoneHWWallet>
    
    public init(store: StoreOf<AddKeystoneHWWallet>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .leading, spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Asset.Assets.Partners.keystoneTitleLogo.image
                            .resizable()
                            .frame(width: 193, height: 32)
                            .padding(.top, 16)

                        Text("Connect Hardware Wallet")
                            .zFont(.semiBold, size: 24, style: Design.Text.primary)
                            .padding(.top, 24)
                        
                        Text("Connect an airgapped hardware wallet that communicates through QR-code.")
                            .zFont(size: 14, style: Design.Text.tertiary)
                            .lineSpacing(1.5)
                            .padding(.top, 8)
                        
                        Text("Have questions?")
                            .zFont(size: 14, style: Design.Text.tertiary)
                            .padding(.top, 8)
                        
                        Text("View Keystone tutorial")
                            .zFont(.semiBold, size: 14, style: Design.Utility.HyperBlue._700)
                            .padding(.top, 4)
                            .underline()
                        
                        Text("How to connect:")
                            .zFont(.semiBold, size: 18, style: Design.Text.primary)
                            .padding(.top, 24)
                        
                        InfoRow(
                            icon: Asset.Assets.Icons.lockUnlocked.image,
                            title: "Unlock your Keystone"
                        )
                        .padding(.top, 16)
                        
                        InfoRow(
                            icon: Asset.Assets.Icons.menu.image,
                            title: "Tap the menu icon"
                        )
                        .padding(.top, 16)

                        InfoRow(
                            icon: Asset.Assets.eyeOn.image,
                            title: "Select Watch-only Wallet"
                        )
                        .padding(.top, 16)

                        InfoRow(
                            icon: Asset.Assets.Icons.zashiLogoSq.image,
                            title: "Select Zashi app"
                        )
                        .padding(.top, 16)
                    }
                }
                .padding(.vertical, 1)
                
                Spacer()
                
                HStack(alignment: .top, spacing: 0) {
                    Asset.Assets.infoCircle.image
                        .zImage(size: 20, style: Design.Text.primary)
                        .padding(.trailing, 12)

                    Text("Security warning here")
                        .zFont(size: 12, style: Design.Text.tertiary)
                }

                ZashiButton(
                    "Continue"
                ) {
                    store.send(.continueTapped)
                }
                .padding(.vertical, 24)
            }
            .screenHorizontalPadding()
            .onAppear { store.send(.onAppear) }
            .zashiBackV2(background: false)
        }
        .navigationBarTitleDisplayMode(.inline)
        .applyScreenBackground()
    }
}

// MARK: Placeholders

extension AddKeystoneHWWallet.State {
    public static let initial = AddKeystoneHWWallet.State()
}

extension AddKeystoneHWWallet {
    public static let initial = StoreOf<AddKeystoneHWWallet>(
        initialState: .initial
    ) {
        AddKeystoneHWWallet()
    }
}

#Preview {
    NavigationView {
        AddKeystoneHWWalletView(store: AddKeystoneHWWallet.initial)
    }
}
