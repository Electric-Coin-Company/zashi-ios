//
//  RequestZecSummaryView.swift
//  Zashi
//
//  Created by Lukáš Korba on 09-30-2024.
//

import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit

import Generated
import UIComponents
import Utils

public struct RequestZecSummaryView: View {
    @Environment(\.colorScheme) var colorScheme

    @Perception.Bindable var store: StoreOf<RequestZec>

    public init(store: StoreOf<RequestZec>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                PrivacyBadge(store.maxPrivacy ? .max : .low)
                    .padding(.top, 24)

                Group {
                    Text(store.requestedZec.decimalString())
                    + Text(" ZEC")
                        .foregroundColor(Design.Text.quaternary.color)
                }
                .zFont(.semiBold, size: 56, style: Design.Text.primary)
                .minimumScaleFactor(0.1)
                .lineLimit(1)
                .padding(.top, 8)

                Button {
                    store.send(.qrCodeTapped)
                } label: {
                    qrCode()
                        .frame(width: 216, height: 216)
                        .onAppear {
                            store.send(.generateQRCode(colorScheme == .dark ? true : false))
                        }
                        .padding(24)
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(store.isQRCodeAppreanceFlipped
                                      ? Asset.Colors.ZDesign.Base.bone.color
                                      : Design.screenBackground.color
                                )
                                .background {
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Design.Surfaces.strokeSecondary.color)
                                }
                        }
                        .padding(.top, 32)
                }

                Spacer()
                
                ZashiButton(
                    "Share QR Code",
                    prefixView:
                        Asset.Assets.Icons.share.image
                        .zImage(size: 20, style: Design.Btns.Primary.fg)
                ) {
                    store.send(.shareQR)
                }
                .padding(.bottom, 8)
                .disabled(store.encryptedOutputToBeShared != nil)
                
                ZashiButton(
                    "Close",
                    type: .ghost
                ) {
                    store.send(.cancelRequestTapped)
                }
                .padding(.bottom, 20)
                
                shareView()
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 20)
            .onAppear { store.send(.onAppear) }
            .onDisappear { store.send(.onDisappear) }
        }
        .screenTitle("Request")
        .screenHorizontalPadding()
        .applyScreenBackground()
        .zashiBack()
    }
}

extension RequestZecSummaryView {
    @ViewBuilder public func qrCode(_ qrText: String = "") -> some View {
        Group {
            if let storedImg = store.storedQR {
                Image(storedImg, scale: 1, label: Text(L10n.qrCodeFor(qrText)))
                    .resizable()
            } else {
                ProgressView()
            }
        }
    }
    
    @ViewBuilder func shareView() -> some View {
        if let encryptedOutput = store.encryptedOutputToBeShared,
           let cgImg = QRCodeGenerator.generateCode(
            from: encryptedOutput,
            color: .black
           ) {
            UIShareDialogView(activityItems: [
                ShareableImage(
                    image: UIImage(cgImage: cgImg),
                    title: "Request ZEC",
                    reason: "Hi, I have generated a ZEC payment request for you using the Zashi app!"
                ), "Hi, I have generated a ZEC payment request for you using the Zashi app! (download link: https://apps.apple.com/app/zashi-zcash-wallet/id1672392439)"
            ]) {
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
        RequestZecView(store: RequestZec.placeholder)
    }
}
