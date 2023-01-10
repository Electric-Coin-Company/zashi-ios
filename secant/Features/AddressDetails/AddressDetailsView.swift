//
//  AddressDetailsView.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 05.07.2022.
//

import SwiftUI
import ComposableArchitecture

struct AddressDetailsView: View {
    let store: AddressDetailsStore
    
    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                Text("Unified Address")
                    .fontWeight(.bold)
                qrCode(viewStore.unifiedAddress)
                    .padding(30)
                
                Text("\(viewStore.unifiedAddress)")
                    .onTapGesture {
                        viewStore.send(.copyUnifiedAddressToPastboard)
                    }

                Text("Sapling Address")
                    .fontWeight(.bold)
                    .padding(.top, 20)
                qrCode(viewStore.saplingAddress)
                    .padding(30)

                Text("\(viewStore.saplingAddress)")
                    .onTapGesture {
                        viewStore.send(.copySaplingAddressToPastboard)
                    }

                Text("Transparent Address")
                    .fontWeight(.bold)
                    .padding(.top, 20)
                qrCode(viewStore.transparentAddress)
                    .padding(30)

                Text("\(viewStore.transparentAddress)")
                    .onTapGesture {
                        viewStore.send(.copyTransparentAddressToPastboard)
                    }
            }
            .padding(20)
            .applyScreenBackground()
        }
    }
}

extension AddressDetailsView {
    func qrCode(_ qrText: String) -> some View {
        Group {
            if let img = QRCodeGenerator.generate(from: qrText) {
                Image(img, scale: 1, label: Text(String(format: NSLocalizedString("QR Code for %@", comment: ""), "\(qrText)") ))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white, lineWidth: 25)
                        .scaleEffect(1.1)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.black, lineWidth: 8)
                        .scaleEffect(1.1)
                    )
            } else {
                Image(systemName: "qrcode")
            }
        }
    }
}

struct AddressDetails_Previews: PreviewProvider {
    static var previews: some View {
    AddressDetailsView(store: .placeholder)
    }
}
