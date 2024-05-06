//
//  AddressDetailsView.swift
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

public struct AddressDetailsView: View {
    public enum AddressType: Equatable {
        case saplingAddress
        case tAddress
        case uaAddress
    }

    @Environment(\.colorScheme) var colorScheme

    let store: AddressDetailsStore
    let networkType: NetworkType
    
    public init(store: AddressDetailsStore, networkType: NetworkType) {
        self.store = store
        self.networkType = networkType
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ScrollView {
                addressBlock(type: .uaAddress, viewStore: viewStore, L10n.AddressDetails.ua, viewStore.unifiedAddress) {
                    viewStore.send(.copyToPastboard(viewStore.unifiedAddress.redacted))
                } shareAction: {
                    viewStore.send(.shareQR(viewStore.unifiedAddress.redacted))
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 20)
                
#if DEBUG
                if networkType == .testnet {
                    addressBlock(type: .saplingAddress, viewStore: viewStore, L10n.AddressDetails.sa, viewStore.saplingAddress) {
                        viewStore.send(.copyToPastboard(viewStore.saplingAddress.redacted))
                    } shareAction: {
                        viewStore.send(.shareQR(viewStore.saplingAddress.redacted))
                    }
                }
#endif
                
                addressBlock(type: .tAddress, viewStore: viewStore, L10n.AddressDetails.ta, viewStore.transparentAddress) {
                    viewStore.send(.copyToPastboard(viewStore.transparentAddress.redacted))
                } shareAction: {
                    viewStore.send(.shareQR(viewStore.transparentAddress.redacted))
                }
                
                shareLogsView(viewStore)
            }
            .padding(.vertical, 1)
            .applyScreenBackground()
        }
    }
    
    @ViewBuilder private func addressBlock(
        type: AddressType,
        viewStore: AddressDetailsViewStore,
        _ title: String,
        _ address: String,
        _ copyAction: @escaping () -> Void,
        shareAction: @escaping () -> Void
    ) -> some View {
        VStack {
            Text(title)
                .font(.custom(FontFamily.Archivo.semiBold.name, size: 16))
                .padding(.bottom, 20)
            
            qrCode(address, type: type, viewStore: viewStore)
                .frame(width: 270, height: 270)
                .padding(.bottom, 20)
            
            Text(address)
                .font(.custom(FontFamily.Inter.regular.name, size: 16))
                .foregroundColor(Asset.Colors.shade47.color)
                .frame(width: 270)
                .padding(.bottom, 20)
            
            HStack(spacing: 25) {
                Button {
                    copyAction()
                } label: {
                    HStack(spacing: 5) {
                        Asset.Assets.copy.image
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 11, height: 11)
                            .foregroundColor(Asset.Colors.primary.color)
                        
                        Text(L10n.AddressDetails.copy)
                            .font(.custom(FontFamily.Inter.bold.name, size: 12))
                            .underline()
                            .foregroundColor(Asset.Colors.primary.color)
                    }
                }
                
                Button {
                    shareAction()
                } label: {
                    HStack(spacing: 5) {
                        Asset.Assets.share.image
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 11, height: 11)
                            .foregroundColor(Asset.Colors.primary.color)

                        Text(L10n.AddressDetails.share)
                            .font(.custom(FontFamily.Inter.bold.name, size: 12))
                            .underline()
                            .foregroundColor(Asset.Colors.primary.color)
                    }
                }
            }
        }
        .padding(.bottom, 40)
    }
}

extension AddressDetailsView {
    public func qrCode(_ qrText: String, type: AddressType, viewStore: AddressDetailsViewStore) -> some View {
        var storedImg: CGImage?
        
        switch type {
        case .saplingAddress:
            storedImg = nil
        case .tAddress:
            storedImg = viewStore.taQR
        case .uaAddress:
            storedImg = viewStore.uaQR
        }
        
        if let storedImg {
            return Image(storedImg, scale: 1, label: Text(L10n.qrCodeFor(qrText)))
                .resizable()
        }
        if let cgImg = QRCodeGenerator.generate(
            from: qrText,
            color: colorScheme == .dark ? Asset.Colors.shade85.systemColor : Asset.Colors.primary.systemColor
        ) {
            return Image(cgImg, scale: 1, label: Text(L10n.qrCodeFor(qrText)))
                .resizable()
        } else {
            return Image(systemName: "qrcode")
                .resizable()
        }
    }
    
    @ViewBuilder func shareLogsView(_ viewStore: AddressDetailsViewStore) -> some View {
        if let addressToShare = viewStore.addressToShare,
           let cgImg = QRCodeGenerator.generate(
            from: addressToShare.data,
            color: colorScheme == .dark ? Asset.Colors.shade85.systemColor : Asset.Colors.primary.systemColor
           ) {
            UIShareDialogView(activityItems: [UIImage(cgImage: cgImg)]) {
                viewStore.send(.shareFinished)
            }
            // UIShareDialogView only wraps UIActivityViewController presentation
            // so frame is set to 0 to not break SwiftUIs layout
            .frame(width: 0, height: 0)
        } else {
            EmptyView()
        }
    }
}

#Preview {
    NavigationView {
        AddressDetailsView(store: .placeholder, networkType: .testnet)
    }
}
