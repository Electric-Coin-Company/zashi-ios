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

    @Perception.Bindable var store: StoreOf<AddressDetails>
    let networkType: NetworkType
    
    public init(store: StoreOf<AddressDetails>, networkType: NetworkType) {
        self.store = store
        self.networkType = networkType
    }
    
    public var body: some View {
        WithPerceptionTracking {
            VStack {
                zashiPicker()

                ScrollView {
                    WithPerceptionTracking {
                        Group {
                            if store.selection == .ua {
                                addressBlock(type: .uaAddress, L10n.AddressDetails.ua, store.unifiedAddress) {
                                    store.send(.copyToPastboard(store.unifiedAddress.redacted))
                                } shareAction: {
                                    store.send(.shareQR(store.unifiedAddress.redacted))
                                }
                            } else {
                                addressBlock(type: .tAddress, L10n.AddressDetails.ta, store.transparentAddress) {
                                    store.send(.copyToPastboard(store.transparentAddress.redacted))
                                } shareAction: {
                                    store.send(.shareQR(store.transparentAddress.redacted))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 20)
                    }
                    
#if DEBUG
                    if networkType == .testnet {
                        addressBlock(type: .saplingAddress, L10n.AddressDetails.sa, store.saplingAddress) {
                            store.send(.copyToPastboard(store.saplingAddress.redacted))
                        } shareAction: {
                            store.send(.shareQR(store.saplingAddress.redacted))
                        }
                    }
#endif
                    
                    shareView()
                }
            }
            .applyScreenBackground()
        }
    }
    
    @ViewBuilder private func addressBlock(
        type: AddressType,
        _ title: String,
        _ address: String,
        _ copyAction: @escaping () -> Void,
        shareAction: @escaping () -> Void
    ) -> some View {
        VStack {
            qrCode(address, type: type)
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
    
    @MainActor @ViewBuilder private func zashiPicker() -> some View {
        ZashiPicker(
            AddressDetails.State.Selection.allCases,
            selection: store.selection,
            itemBuilder: { item in
                WithPerceptionTracking {
                    Text(item == .ua
                         ? L10n.AddressDetails.ua
                         :L10n.AddressDetails.ta
                    ).tag(item == .ua
                          ? AddressDetails.State.Selection.ua
                          : AddressDetails.State.Selection.transparent
                    )
                    .foregroundColor(
                        store.selection == item
                        ? Asset.Colors.pickerTitleSelected.color
                        : Asset.Colors.pickerTitleUnselected.color
                    )
                    .padding(.vertical, 12)
                    .padding(.horizontal, 8)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .font(.custom(FontFamily.Archivo.semiBold.name, size: 12))
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.150)) {
                            store.selection = item
                        }
                    }
                    .background(
                        store.selection == item
                        ? Asset.Colors.pickerSelection.color
                        : Asset.Colors.pickerBcg.color
                    )
                }
            }
        )
        .border(Asset.Colors.pickerBcg.color, width: 4)
        .frame(width: 270)
        .padding(.top, 50)
    }
}

extension AddressDetailsView {
    public func qrCode(_ qrText: String, type: AddressType) -> some View {
        var storedImg: CGImage?
        
        switch type {
        case .saplingAddress:
            storedImg = nil
        case .tAddress:
            storedImg = store.taQR
        case .uaAddress:
            storedImg = store.uaQR
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
    
    @ViewBuilder func shareView() -> some View {
        if let addressToShare = store.addressToShare,
           let cgImg = QRCodeGenerator.generate(
            from: addressToShare.data,
            color: colorScheme == .dark ? Asset.Colors.shade85.systemColor : Asset.Colors.primary.systemColor
           ) {
            UIShareDialogView(activityItems: [UIImage(cgImage: cgImg)]) {
                store.send(.shareFinished)
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
        AddressDetailsView(store: AddressDetails.placeholder, networkType: .testnet)
    }
}

// MARK: - Placeholders

extension AddressDetails.State {
    public static let initial = AddressDetails.State()
    
    public static let demo = AddressDetails.State(
        uAddress: try! UnifiedAddress(
            encoding: "utest1vergg5jkp4xy8sqfasw6s5zkdpnxvfxlxh35uuc3me7dp596y2r05t6dv9htwe3pf8ksrfr8ksca2lskzjanqtl8uqp5vln3zyy246ejtx86vqftp73j7jg9099jxafyjhfm6u956j3",
            network: .testnet)
    )
}

extension AddressDetails {
    public static let placeholder = StoreOf<AddressDetails>(
        initialState: .initial
    ) {
        AddressDetails()
    }
}
