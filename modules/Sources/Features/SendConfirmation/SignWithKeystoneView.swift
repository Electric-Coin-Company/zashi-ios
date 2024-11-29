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
import URKit
import Vendors

public struct SignWithKeystoneView: View {
    @Perception.Bindable var store: StoreOf<SendConfirmation>
    let encoder: UREncoder

    public init(store: StoreOf<SendConfirmation>) {
        self.store = store

        let cosmosSignRequest = CosmosSignRequest(
            requestId: "7AFD5E09-9267-43FB-A02E-08C4A09417EC",
            signData: "7B226163636F756E745F6E756D626572223A22323930353536222C22636861696E5F6964223A226F736D6F2D746573742D34222C22666565223A7B22616D6F756E74223A5B7B22616D6F756E74223A2231303032222C2264656E6F6D223A22756F736D6F227D5D2C22676173223A22313030313936227D2C226D656D6F223A22222C226D736773223A5B7B2274797065223A22636F736D6F732D73646B2F4D736753656E64222C2276616C7565223A7B22616D6F756E74223A5B7B22616D6F756E74223A223132303030303030222C2264656E6F6D223A22756F736D6F227D5D2C2266726F6D5F61646472657373223A226F736D6F31667334396A7867797A30306C78363436336534767A767838353667756C64756C6A7A6174366D222C22746F5F61646472657373223A226F736D6F31667334396A7867797A30306C78363436336534767A767838353667756C64756C6A7A6174366D227D7D5D2C2273657175656E6365223A2230227D",
            dataType: .amino,
            accounts: [
                CosmosSignRequest.Account(
                    path: "m/44'/118'/0'/0/0",
                    xfp: "f23f9fd2",
                    address: "4c2a59190413dff36aba8e6ac130c7a691cfb79f"
                )
            ]
        )
        
        let keystoneSDK = KeystoneSDK().cosmos;
        let qrCode = try! keystoneSDK.generateSignRequest(cosmosSignRequest: cosmosSignRequest);
        self.encoder = qrCode;
    }
    
    public var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            Asset.Assets.Partners.keystoneLogoLight.image
                                .resizable()
                                .frame(width: 24, height: 24)
                                .padding(8)
                                .background {
                                    Circle()
                                        .fill(Design.Surfaces.brandFg.color)
                                }
                                .padding(.trailing, 12)
                            
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Keystone")
                                    .zFont(.semiBold, size: 16, style: Design.Text.primary)
                                
                                Text("0x8EgiqpBzgfeFqB6cde...")
                                    .zFont(size: 12, style: Design.Text.tertiary)
                            }
                            
                            Spacer()
                            
                            Text("Hardware")
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

                        Text("Scan with your Keystone wallet")
                            .zFont(.medium, size: 16, style: Design.Text.primary)
                            .padding(.top, 32)
                        
                        Text("After you have signed with Keystone, tap on the Get Signature button below.")
                            .zFont(size: 14, style: Design.Text.tertiary)
                            .screenHorizontalPadding()
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 4)
                    }
                }

                Spacer()
                
                ZashiButton(
                    "Get Signature"
                ) {
                    store.send(.getSignatureTapped)
                }
                .padding(.bottom, 8)

                ZashiButton(
                    "Reject",
                    type: .ghost
                ) {
                    store.send(.rejectTapped)
                }
                .padding(.bottom, 20)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 20)
        }
        .screenHorizontalPadding()
        .applyScreenBackground()
        .zashiBack(hidden: true)
        .screenTitle("SIGN TRANSACTION")
    }
}
 
