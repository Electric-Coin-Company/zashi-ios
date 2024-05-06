//
//  ScanView.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 16.05.2022.
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents

public struct ScanView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) var openURL

    let store: StoreOf<Scan>
    
    public init(store: StoreOf<Scan>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            ZStack {
                GeometryReader { proxy in
                    QRCodeScanView(
                        rectOfInterest: normalizedRectOfInterest(proxy.size),
                        onQRScanningDidFail: { store.send(.scanFailed) },
                        onQRScanningSucceededWithCode: { store.send(.scan($0.redacted)) }
                    )
                    
                    frameOfInterest(proxy.size)
                    
                    if store.isTorchAvailable {
                        torchButton(store, size: proxy.size)
                    }
                }
                
                VStack {
                    Spacer()
                    
                    Text(store.info)
                        .font(Font.custom("Inter", size: 14))
                        .foregroundColor(Asset.Colors.secondary.color)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 20)
                    
                    if !store.isCameraEnabled {
                        Button(L10n.Scan.openSettings.uppercased()) {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                openURL(url)
                            }
                        }
                        .zcashStyle(.secondary)
                        .padding(.horizontal, 50)
                        .padding(.bottom, 70)
                    } else {
                        Button(L10n.General.cancel.uppercased()) {
                            store.send(.cancelPressed)
                        }
                        .zcashStyle(.secondary)
                        .padding(.horizontal, 50)
                        .padding(.bottom, 70)
                    }
                }
                .padding(.horizontal, 30)
            }
            .edgesIgnoringSafeArea(.all)
            .ignoresSafeArea()
            .applyScreenBackground()
            .onAppear { store.send(.onAppear) }
            .onDisappear { store.send(.onDisappear) }
            .zashiBack(hidden: store.isCameraEnabled, invertedColors: colorScheme == .light)
        }
    }
}

extension ScanView {
    func torchButton(_ store: StoreOf<Scan>, size: CGSize) -> some View {
        let center = ScanView.rectOfInterest(size).origin
        let frameHalfSize = ScanView.frameSize(size) * 0.5
        
        return Button {
            store.send(.torchPressed)
        } label: {
            if store.isTorchOn {
                Asset.Assets.torchOff.image
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.white)
            } else {
                Asset.Assets.torchOn.image
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.white)
            }
        }
        .position(
            x: center.x + frameHalfSize - 5,
            y: center.y + frameHalfSize + 20
        )
    }

    func frameOfInterest(_ size: CGSize) -> some View {
        let center = ScanView.rectOfInterest(size).origin
        let frameSize = ScanView.frameSize(size)
        let halfSize = frameSize * 0.5
        let cornersLength = 36.0
        let cornersHalfLength = cornersLength * 0.5
        let leadMarkColor = Color.white

        return ZStack {
            Color.black
                .opacity(0.65)
                .edgesIgnoringSafeArea(.all)
                .ignoresSafeArea()
                .reverseMask {
                    Rectangle()
                        .frame(
                            width: frameSize,
                            height: frameSize,
                            alignment: .center
                        )
                        .position(
                            x: center.x,
                            y: center.y
                        )
                }

            // horizontal lead marks
            leadMarkColor
                .frame(width: cornersLength, height: 1)
                .position(x: center.x - halfSize + cornersHalfLength, y: center.y - halfSize)
            leadMarkColor
                .frame(width: cornersLength, height: 1)
                .position(x: center.x + halfSize - cornersHalfLength, y: center.y - halfSize)
            leadMarkColor
                .frame(width: cornersLength, height: 1)
                .position(x: center.x - halfSize + cornersHalfLength, y: center.y + halfSize)
            leadMarkColor
                .frame(width: cornersLength, height: 1)
                .position(x: center.x + halfSize - cornersHalfLength, y: center.y + halfSize)

            // vertical lead marks
            leadMarkColor
                .frame(width: 1, height: cornersLength)
                .position(x: center.x - halfSize, y: center.y - halfSize + cornersHalfLength)
            leadMarkColor
                .frame(width: 1, height: cornersLength)
                .position(x: center.x - halfSize, y: center.y + halfSize - cornersHalfLength)
            leadMarkColor
                .frame(width: 1, height: cornersLength)
                .position(x: center.x + halfSize, y: center.y - halfSize + cornersHalfLength)
            leadMarkColor
                .frame(width: 1, height: cornersLength)
                .position(x: center.x + halfSize, y: center.y + halfSize - cornersHalfLength)
        }
    }
}

extension View {
    @inlinable
    public func reverseMask<Mask: View>(
        alignment: Alignment = .center,
        @ViewBuilder _ mask: () -> Mask
    ) -> some View {
        self.mask {
            Rectangle()
                .overlay(alignment: alignment) {
                    mask()
                        .blendMode(.destinationOut)
                }
        }
    }
}

extension ScanView {
    static func frameSize(_ size: CGSize) -> CGFloat {
        size.width * 0.55
    }

    static func rectOfInterest(_ size: CGSize) -> CGRect {
        CGRect(
            x: size.width * 0.5,
            y: size.height * 0.5,
            width: frameSize(size),
            height: frameSize(size)
        )
    }

    func normalizedRectOfInterest(_ size: CGSize) -> CGRect {
        CGRect(
            x: 0.25,
            y: 0.25,
            width: 0.5,
            height: 0.5
        )
    }
}

// MARK: - Previews

struct ScanView_Previews: PreviewProvider {
    static var previews: some View {
        ScanView(store: Scan.placeholder)
    }
}

// MARK: Placeholders

extension Scan.State {
    public static var initial = Scan.State()
}

extension Scan {
    public static let placeholder = StoreOf<Scan>(
        initialState: .initial
    ) {
        Scan()
    }
}
