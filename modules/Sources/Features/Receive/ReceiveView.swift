//
//  ReceiveView.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 05.07.2022.
//

import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit

import Generated
import UIComponents
import Utils

public struct ReceiveView: View {
    @Environment(\.colorScheme) var colorScheme
    
    public enum AddressType: Equatable {
        case saplingAddress
        case tAddress
        case uaAddress
    }

    @Perception.Bindable var store: StoreOf<Receive>
    let networkType: NetworkType
    
    @State private var currentFocus = AddressType.uaAddress
    
    public init(store: StoreOf<Receive>, networkType: NetworkType) {
        self.store = store
        self.networkType = networkType
    }
    
    public var body: some View {
        WithPerceptionTracking {
            ScrollView {
                WithPerceptionTracking {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text("Receive Zcash")
                                .zFont(.semiBold, size: 28, style: Design.Text.primary)
                                .lineLimit(1)
                                .padding(.top, 24)
                                .padding(.bottom, 6)
                            
                            Spacer()
                        }
                        
                        Text("Prioritize using your shielded address for maximum privacy.")
                            .zFont(size: 16, style: Design.Text.secondary)
                    }
                    .padding(.horizontal, 20)
                    .onAppear {
                        currentFocus = .uaAddress
                    }

//                    HStack(alignment: .top, spacing: 0) {
//                        Asset.Assets.infoOutline.image
//                            .zImage(size: 20, style: Design.Text.tertiary)
//                            .padding(.trailing, 12)
//                        
//                        Text("Prioritize using shielded address for maximum privacy.")
//                            .zFont(size: 12, style: Design.Text.tertiary)
//                            .padding(.top, 3)
//                        
//                        Spacer(minLength: 0)
//                    }
//                    .padding(.horizontal, 20)
//                    .padding(.top, 24)

                    addressBlock(
                        prefixIcon: Asset.Assets.Brandmarks.brandmarkMax.image,
                        title: "Zcash Shielded Address",
                        address: store.unifiedAddress,
                        postfixIcon: Asset.Assets.Icons.shieldTickFilled.image,
                        iconFg: Design.Utility.Purple._800,
                        iconBg: Design.Utility.Purple._100,
                        bcgColor: Design.Utility.Purple._50.color,
                        expanded: currentFocus == .uaAddress
                    ) {
                        store.send(.copyToPastboard(store.unifiedAddress.redacted))
                    } qrAction: {
                        store.send(.addressDetailsRequest(store.unifiedAddress.redacted, true))
                    } requestAction: {
                        store.send(.requestTapped(store.unifiedAddress.redacted, true))
                    }
                    .onTapGesture {
                        withAnimation {
                            currentFocus = .uaAddress
                        }
                    }
                    .padding(.top, 24)

                    addressBlock(
                        prefixIcon: Asset.Assets.Brandmarks.brandmarkLow.image,
                        title: "Zcash Transparent Address",
                        address: store.transparentAddress,
                        iconFg: Design.Text.primary,
                        iconBg: Design.Surfaces.bgTertiary,
                        bcgColor: Design.Utility.Gray._50.color,
                        expanded: currentFocus == .tAddress
                    ) {
                        store.send(.copyToPastboard(store.transparentAddress.redacted))
                    } qrAction: {
                        store.send(.addressDetailsRequest(store.transparentAddress.redacted, false))
                    } requestAction: {
                        store.send(.requestTapped(store.transparentAddress.redacted, false))
                    }
                    .onTapGesture {
                        withAnimation {
                            currentFocus = .tAddress
                        }
                    }
#if DEBUG
                    if networkType == .testnet {
                        addressBlock(
                            prefixIcon: Asset.Assets.Brandmarks.brandmarkLow.image,
                            title: "Zcash Sapling Address",
                            address: store.saplingAddress,
                            iconFg: Design.Text.primary,
                            iconBg: Design.Surfaces.bgTertiary,
                            bcgColor: .clear,
                            expanded: currentFocus == .saplingAddress
                        ) {
                            store.send(.copyToPastboard(store.saplingAddress.redacted))
                        } qrAction: {
                            store.send(.addressDetailsRequest(store.saplingAddress.redacted, true))
                        } requestAction: {
                            store.send(.requestTapped(store.saplingAddress.redacted, true))
                        }
                        .onTapGesture {
                            currentFocus = .saplingAddress
                        }
                    }
#endif
                }
            }
            .padding(.vertical, 1)
        }
        .padding(.horizontal, 4)
        .applyScreenBackground()
    }
    
    @ViewBuilder private func addressBlock(
        prefixIcon: Image,
        title: String,
        address: String,
        postfixIcon: Image? = nil,
        iconFg: Colorable,
        iconBg: Colorable,
        bcgColor: Color,
        expanded: Bool,
        copyAction: @escaping () -> Void,
        qrAction: @escaping () -> Void,
        requestAction: @escaping () -> Void
    ) -> some View {
        VStack {
            HStack(alignment: .top, spacing: 0) {
                prefixIcon
                    .resizable()
                    .frame(width: 32, height: 32)
                    .padding(.trailing, 16)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .zFont(.semiBold, size: 16, style: Design.Text.primary)
                        .minimumScaleFactor(0.5)
                        .padding(.bottom, 4)
                    
                    Text(address.zip316)
                        .zFont(size: 14, style: Design.Text.tertiary)
                        //.truncationMode(.middle)
                        //.frame(maxWidth: 110)
                        .padding(.bottom, expanded ? 10 : 0)
                }
                .lineLimit(1)
                
                Spacer(minLength: 0)
                
                if let postfixIcon {
                    postfixIcon
                        .zImage(size: 24, style: Design.Utility.Purple._700)
                        .padding(.leading, 16)
                }
            }
            .padding(.horizontal, 20)
            
            if expanded {
                HStack(spacing: 8) {
                    button("Copy", fill: iconBg.color, icon: Asset.Assets.copy.image) {
                        copyAction()
                    }
                    
                    button("QR Code", fill: iconBg.color, icon: Asset.Assets.Icons.qr.image) {
                        qrAction()
                    }
                    
                    button("Request", fill: iconBg.color, icon: Asset.Assets.Icons.coinsHand.image) {
                        requestAction()
                    }
                }
                .zFont(.medium, size: 14, style: iconFg)
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 20)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(bcgColor)
        }
    }
    
    private func button(_ title: String, fill: Color, icon: Image, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            ZStack {
                icon
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 16, height: 16)
                    .offset(x: 0, y: -10)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(fill)
                    }
                
                Text(title)
                    .offset(x: 0, y: 10)
            }
        }
    }
}

#Preview {
    NavigationView {
        ReceiveView(store: Receive.placeholder, networkType: .testnet)
    }
}

// MARK: - Placeholders

extension Receive.State {
    public static let initial = Receive.State()
    
    public static let demo = Receive.State(
        uAddress: try! UnifiedAddress(
            encoding: "utest1vergg5jkp4xy8sqfasw6s5zkdpnxvfxlxh35uuc3me7dp596y2r05t6dv9htwe3pf8ksrfr8ksca2lskzjanqtl8uqp5vln3zyy246ejtx86vqftp73j7jg9099jxafyjhfm6u956j3",
            network: .testnet)
    )
}

extension Receive {
    public static let placeholder = StoreOf<Receive>(
        initialState: .initial
    ) {
        Receive()
    }
}
