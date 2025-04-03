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

    @Perception.Bindable var store: StoreOf<Receive>
    let networkType: NetworkType

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
                            Text(L10n.Receive.title)
                                .zFont(.semiBold, size: 28, style: Design.Text.primary)
                                .lineLimit(1)
                                .padding(.top, 24)
                                .padding(.bottom, 6)
                            
                            Spacer()
                        }
                        
                        Text(L10n.Receive.warning)
                            .zFont(size: 16, style: Design.Text.secondary)
                    }
                    .padding(.horizontal, 20)
                    .onAppear {
                        store.send(.updateCurrentFocus(.uaAddress))
                    }

                    if store.selectedWalletAccount?.vendor == .keystone {
                        addressBlock(
                            prefixIcon: Asset.Assets.Brandmarks.brandmarkKeystone.image,
                            title: L10n.Accounts.Keystone.shieldedAddress,
                            address: store.unifiedAddress,
                            postfixIcon: Asset.Assets.Icons.shieldTickFilled.image,
                            iconFg: Design.Utility.Indigo._800,
                            iconBg: Design.Utility.Indigo._100,
                            bcgColor: Design.Utility.Indigo._50.color(colorScheme),
                            expanded: store.currentFocus == .uaAddress
                        ) {
                            store.send(.copyToPastboard(store.unifiedAddress.redacted))
                        } qrAction: {
                            store.send(.addressDetailsRequest(store.unifiedAddress.redacted, true))
                        } requestAction: {
                            store.send(.requestTapped(store.unifiedAddress.redacted, true))
                        }
                        .onTapGesture {
                            store.send(.updateCurrentFocus(.uaAddress), animation: .default)
                        }
                        .padding(.top, 24)
                        
                        if let transparentAddress = store.selectedWalletAccount?.transparentAddress {
                            addressBlock(
                                prefixIcon: Asset.Assets.Brandmarks.brandmarkKeystone.image,
                                title: L10n.Accounts.Keystone.transparentAddress,
                                address: transparentAddress,
                                iconFg: Design.Text.primary,
                                iconBg: Design.Surfaces.bgTertiary,
                                bcgColor: Design.Utility.Gray._50.color(colorScheme),
                                expanded: store.currentFocus == .tAddress
                            ) {
                                store.send(.copyToPastboard(store.transparentAddress.redacted))
                            } qrAction: {
                                store.send(.addressDetailsRequest(store.transparentAddress.redacted, false))
                            } requestAction: {
                                store.send(.requestTapped(store.transparentAddress.redacted, false))
                            }
                            .onTapGesture {
                                store.send(.updateCurrentFocus(.tAddress), animation: .default)
                            }
                        }
                    } else {
                        addressBlock(
                            prefixIcon: Asset.Assets.Brandmarks.brandmarkMax.image,
                            title: L10n.Accounts.Zashi.shieldedAddress,
                            address: store.unifiedAddress,
                            postfixIcon: Asset.Assets.Icons.shieldTickFilled.image,
                            iconFg: Design.Utility.Purple._800,
                            iconBg: Design.Utility.Purple._100,
                            bcgColor: Design.Utility.Purple._50.color(colorScheme),
                            expanded: store.currentFocus == .uaAddress
                        ) {
                            store.send(.copyToPastboard(store.unifiedAddress.redacted))
                        } qrAction: {
                            store.send(.addressDetailsRequest(store.unifiedAddress.redacted, true))
                        } requestAction: {
                            store.send(.requestTapped(store.unifiedAddress.redacted, true))
                        }
                        .onTapGesture {
                            store.send(.updateCurrentFocus(.uaAddress), animation: .default)
                        }
                        .padding(.top, 24)
                        
                        addressBlock(
                            prefixIcon: Asset.Assets.Brandmarks.brandmarkLow.image,
                            title: L10n.Accounts.Zashi.transparentAddress,
                            address: store.transparentAddress,
                            iconFg: Design.Text.primary,
                            iconBg: Design.Surfaces.bgTertiary,
                            bcgColor: Design.Utility.Gray._50.color(colorScheme),
                            expanded: store.currentFocus == .tAddress
                        ) {
                            store.send(.copyToPastboard(store.transparentAddress.redacted))
                        } qrAction: {
                            store.send(.addressDetailsRequest(store.transparentAddress.redacted, false))
                        } requestAction: {
                            store.send(.requestTapped(store.transparentAddress.redacted, false))
                        }
                        .onTapGesture {
                            store.send(.updateCurrentFocus(.tAddress), animation: .default)
                        }
#if DEBUG
                        if networkType == .testnet {
                            addressBlock(
                                prefixIcon: Asset.Assets.Brandmarks.brandmarkLow.image,
                                title: L10n.Receive.saplingAddress,
                                address: store.saplingAddress,
                                iconFg: Design.Text.primary,
                                iconBg: Design.Surfaces.bgTertiary,
                                bcgColor: .clear,
                                expanded: store.currentFocus == .saplingAddress
                            ) {
                                store.send(.copyToPastboard(store.saplingAddress.redacted))
                            } qrAction: {
                                store.send(.addressDetailsRequest(store.saplingAddress.redacted, true))
                            } requestAction: {
                                store.send(.requestTapped(store.saplingAddress.redacted, true))
                            }
                            .onTapGesture {
                                store.send(.updateCurrentFocus(.saplingAddress))
                            }
                        }
#endif
                    }
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
                        .zFont(addressFont: true, size: 14, style: Design.Text.tertiary)
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
                    button(
                        L10n.Receive.copy,
                        fill: iconBg.color(colorScheme),
                        icon: Asset.Assets.copy.image
                    ) {
                        copyAction()
                    }
                    
                    button(
                        L10n.Receive.qrCode,
                        fill: iconBg.color(colorScheme),
                        icon: Asset.Assets.Icons.qr.image
                    ) {
                        qrAction()
                    }
                    
                    button(
                        L10n.Receive.request,
                        fill: iconBg.color(colorScheme),
                        icon: Asset.Assets.Icons.coinsHand.image
                    ) {
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
}

extension Receive {
    public static let placeholder = StoreOf<Receive>(
        initialState: .initial
    ) {
        Receive()
    }
}
