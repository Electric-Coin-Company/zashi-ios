//
//  SignWithKeystoneView.swift
//  Zashi
//
//  Created by Lukáš Korba on 2024-11-29.
//

import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit

import Generated
import UIComponents
import Utils
import KeystoneSDK
import Vendors
import SDKSynchronizer
import Scan

public struct SignWithKeystoneView: View {
    @Perception.Bindable var store: StoreOf<SendConfirmation>

    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    
    let tokenName: String
    
    public init(store: StoreOf<SendConfirmation>, tokenName: String) {
        self.store = store
        self.tokenName = tokenName
    }

    public var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            Asset.Assets.Partners.keystoneLogo.image
                                .resizable()
                                .frame(width: 24, height: 24)
                                .padding(8)
                                .background {
                                    Circle()
                                        .fill(Design.Surfaces.bgAlt.color)
                                }
                                .padding(.trailing, 12)
                            
                            VStack(alignment: .leading, spacing: 0) {
                                Text(L10n.Accounts.keystone)
                                    .zFont(.semiBold, size: 16, style: Design.Text.primary)
                                
                                Text(store.selectedWalletAccount?.unifiedAddress?.zip316 ?? "")
                                    .zFont(addressFont: true, size: 12, style: Design.Text.tertiary)
                            }
                            
                            Spacer()
                            
                            Text(L10n.Keystone.SignWith.hardware)
                                .zFont(.medium, size: 12, style: Design.Utility.HyperBlue._700)
                                .padding(.vertical, 2)
                                .padding(.horizontal, 8)
                                .background {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Design.Utility.HyperBlue._50.color)
                                        .background {
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Design.Utility.HyperBlue._200.color)
                                        }
                                }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Design.Surfaces.strokeSecondary.color)
                        }
                        .padding(.top, 40)

                        if let pczt = store.pczt, let encoder = sdkSynchronizer.urEncoderForPCZT(Pczt(pczt)) {
                            AnimatedQRCode(urEncoder: encoder)
                                .frame(width: 216, height: 216)
                                .padding(24)
                                .background {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Asset.Colors.ZDesign.Base.bone.color)
                                        .background {
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Design.Surfaces.strokeSecondary.color)
                                        }
                                }
                                .padding(.top, 32)
                        } else {
                            VStack {
                                ProgressView()
                            }
                            .frame(width: 216, height: 216)
                            .padding(24)
                            .background {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Asset.Colors.ZDesign.Base.bone.color)
                                    .background {
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Design.Surfaces.strokeSecondary.color)
                                    }
                            }
                            .padding(.top, 32)
                        }

                        Text(L10n.Keystone.SignWith.title)
                            .zFont(.medium, size: 16, style: Design.Text.primary)
                            .padding(.top, 32)
                        
                        Text(L10n.Keystone.SignWith.desc)
                            .zFont(size: 14, style: Design.Text.tertiary)
                            .screenHorizontalPadding()
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 4)
                    }
                }

                #if DEBUG
                ZashiButton(
                    "Share PCZT",
                    type: .ghost
                ) {
                    store.send(.sharePCZT)
                }
                .padding(.top, 16)
                #endif

                Spacer()

                ZashiButton(
                    L10n.Keystone.SignWith.getSignature
                ) {
                    store.send(.getSignatureTapped)
                }
                .padding(.bottom, 8)

                ZashiButton(
                    L10n.Keystone.SignWith.reject,
                    type: .ghost
                ) {
                    store.send(.rejectTapped)
                }
                .padding(.bottom, 20)
                
                shareView()
            }
            .onAppear { store.send(.onAppear) }
            .frame(maxWidth: .infinity)
            .padding(.top, 20)
            .navigationLinkEmpty(
                isActive: store.bindingForStack(.scan),
                destination: {
                    ScanView(
                        store: store.scanStore()
                    )
                    .navigationLinkEmpty(
                        isActive: store.bindingForStack(.sending),
                        destination: {
                            SendingView(store: store, tokenName: tokenName)
                        }
                    )
                }
            )
        }
        .screenHorizontalPadding()
        .applyScreenBackground()
        .zashiBack(hidden: true)
        .screenTitle(L10n.Keystone.SignWith.signTransaction)
    }
}
 
extension SignWithKeystoneView {
    @ViewBuilder func shareView() -> some View {
        if let pczt = store.pcztToShare {
            UIShareDialogView(activityItems: [pczt]) {
                store.send(.shareFinished)
            }
            .frame(width: 0, height: 0)
        }
    }
}
