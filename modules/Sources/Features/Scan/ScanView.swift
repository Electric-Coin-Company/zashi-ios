//
//  ScanStore.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 16.05.2022.
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents

public struct ScanView: View {
    @Environment(\.presentationMode) var presentationMode

    let store: ScanStore

    public init(store: ScanStore) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            GeometryReader { proxy in
                ZStack {
                    QRCodeScanView(
                        rectOfInterest: normalizedRectOfInterest(proxy.size),
                        onQRScanningDidFail: { viewStore.send(.scanFailed) },
                        onQRScanningSucceededWithCode: { viewStore.send(.scan($0.redacted)) }
                    )
                    
                    backButton
                    
                    if viewStore.isTorchAvailable {
                        torchButton(viewStore)
                    }
                    
                    frameOfInterest(proxy.size)
                    
                    VStack {
                        Spacer()
                        
                        Text(L10n.Scan.info)
                            .padding(.bottom, 10)
                        
                        if let scannedValue = viewStore.scannedValue {
                            Text(scannedValue)
                                .foregroundColor(viewStore.isValidValue ? .green : .red)
                        } else {
                            Text(L10n.Scan.scanning)
                        }
                    }
                    .padding()
                }
                .navigationBarHidden(true)
                .applyScreenBackground()
                .onAppear { viewStore.send(.onAppear) }
                .onDisappear { viewStore.send(.onDisappear) }
            }
            .ignoresSafeArea()
        }
        .alert(store: store.scope(
            state: \.$alert,
            action: { .alert($0) }
        ))
    }
}

extension ScanView {
    var backButton: some View {
        VStack {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "arrow.backward")
                        .foregroundColor(Asset.Colors.Mfp.background.color)
                        .font(.system(size: 30.0))
                })
                .padding(.top, 10)

                Spacer()
            }
            .padding()
            
            Spacer()
        }
        .padding()
    }

    func torchButton(_ viewStore: ScanViewStore) -> some View {
        VStack {
            HStack {
                Spacer()

                Button(
                    action: { viewStore.send(.torchPressed) },
                    label: {
                        Image(
                            systemName: viewStore.isTorchOn ? "lightbulb.fill" : "lightbulb.slash"
                        )
                        .foregroundColor(Asset.Colors.Mfp.background.color)
                        .font(.system(size: 30.0))
                    }
                )
                .padding(.top, 10)
            }
            .padding()
            
            Spacer()
        }
        .padding()
    }

    func frameOfInterest(_ size: CGSize) -> some View {
        Rectangle()
            .stroke(Asset.Colors.Mfp.background.color, lineWidth: 5.0)
            .frame(
                width: frameSize(size),
                height: frameSize(size),
                alignment: .center
            )
            .edgesIgnoringSafeArea(.all)
            .ignoresSafeArea()
            .position(
                x: rectOfInterest(size).origin.x,
                y: rectOfInterest(size).origin.y
            )
    }
}

extension ScanView {
    func frameSize(_ size: CGSize) -> CGFloat {
        size.width * 0.55
    }

    func rectOfInterest(_ size: CGSize) -> CGRect {
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
        ScanView(store: .placeholder)
    }
}
