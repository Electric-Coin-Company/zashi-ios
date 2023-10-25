//
//  AddressDetailsView.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 05.07.2022.
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents
import Utils

public struct AddressDetailsView: View {
    let store: AddressDetailsStore

    public init(store: AddressDetailsStore) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                addressBlock(L10n.AddressDetails.ua, viewStore.unifiedAddress) {
                    viewStore.send(.copyUnifiedAddressToPastboard)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 20)
                
                addressBlock(L10n.AddressDetails.sa, viewStore.saplingAddress) {
                    viewStore.send(.copySaplingAddressToPastboard)
                }
                
                addressBlock(L10n.AddressDetails.ta, viewStore.transparentAddress) {
                    viewStore.send(.copyTransparentAddressToPastboard)
                }
            }
            .padding(.vertical, 1)
            .applyScreenBackground()
        }
    }
    
    @ViewBuilder private func addressBlock(
        _ title: String,
        _ address: String,
        _ tapToCopyAction: @escaping () -> Void
    ) -> some View {
        VStack {
            Text(title)
                .font(.custom(FontFamily.Archivo.semiBold.name, size: 16))
                .padding(.bottom, 20)
            
            qrCode(address)
                .frame(width: 270, height: 270)
                .padding(.bottom, 20)
            
            Text(address)
                .font(.custom(FontFamily.Inter.regular.name, size: 16))
                .foregroundColor(Asset.Colors.suppressed47.color)
                .frame(width: 270)
                .padding(.bottom, 20)
            
            Button {
                tapToCopyAction()
            } label: {
                Text(L10n.AddressDetails.tapToCopy)
                    .font(.custom(FontFamily.Inter.bold.name, size: 11))
                    .underline()
                    .foregroundColor(Asset.Colors.primary.color)
            }
        }
        .padding(.bottom, 40)
    }
}

extension AddressDetailsView {
    public func qrCode(_ qrText: String) -> some View {
        Group {
            if let img = QRCodeGenerator.generate(from: qrText) {
                Image(img, scale: 1, label: Text(L10n.qrCodeFor(qrText)))
                    .resizable()
            } else {
                Image(systemName: "qrcode")
                    .resizable()
            }
        }
    }
}

#Preview {
    NavigationView {
        AddressDetailsView(store: .placeholder)
    }
}
