//
//  ScanStore.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 16.05.2022.
//

import SwiftUI
import CoreImage
import ComposableArchitecture
import Foundation

import CaptureDevice
import QRImageDetector
import Utils
import Models
import URIParser
import ZcashLightClientKit
import Generated
import ZcashSDKEnvironment
import ZcashPaymentURI

@Reducer
public struct Scan {
    private let CancelId = UUID()

    public enum ScanImageResult: Equatable {
        case invalidQRCode
        case noQRCodeFound
        case severalQRCodesFound
    }
    
    @ObservableState
    public struct State: Equatable {
        public var info = ""
        public var isTorchAvailable = false
        public var isTorchOn = false
        public var isCameraEnabled = true
        
        public init(
            info: String = "",
            isTorchAvailable: Bool = false,
            isTorchOn: Bool = false,
            isCameraEnabled: Bool = true
        ) {
            self.info = info
            self.isTorchAvailable = isTorchAvailable
            self.isTorchOn = isTorchOn
        }
    }

    @Dependency(\.captureDevice) var captureDevice
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.qrImageDetector) var qrImageDetector
    @Dependency(\.uriParser) var uriParser
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    public enum Action: Equatable {
        case cancelPressed
        case clearInfo
        case libraryImage(UIImage?)
        case onAppear
        case onDisappear
        case found(RedactableString)
        case foundRP(ParserResult)
        case scanFailed(ScanImageResult)
        case scan(RedactableString)
        case torchPressed
    }
    
    public init() { }

    // swiftlint:disable:next cyclomatic_complexity
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                // reset the values
                state.isTorchOn = false
                // check the torch availability
                state.isTorchAvailable = captureDevice.isTorchAvailable()
                if !captureDevice.isAuthorized() {
                    state.isCameraEnabled = false
                    state.info = L10n.Scan.cameraSettings
                }
                return .none
                
            case .onDisappear:
                return .cancel(id: CancelId)
                
            case .cancelPressed:
                return .none
                
            case .clearInfo:
                state.info = ""
                return .cancel(id: CancelId)

            case .found:
                return .none

            case .foundRP:
                return .none

            case .libraryImage(let image):
                guard let codes = qrImageDetector.check(image) else {
                    return .send(.scanFailed(.noQRCodeFound))
                }
                
                guard codes.count == 1 else {
                    return .send(.scanFailed(.severalQRCodesFound))
                }
                
                guard let code = codes.first else {
                    return .send(.scanFailed(.noQRCodeFound))
                }
                
                if uriParser.isValidURI(code, zcashSDKEnvironment.network.networkType) {
                    return .send(.found(code.redacted))
                } else {
                    return .send(.scanFailed(.noQRCodeFound))
                }

            case .scanFailed(let result):
                switch result {
                case .invalidQRCode:
                    state.info = L10n.Scan.invalidQR
                case .noQRCodeFound:
                    state.info = L10n.Scan.invalidImage
                case .severalQRCodesFound:
                    state.info = L10n.Scan.severalCodesFound
                }
                return .concatenate(
                    Effect.cancel(id: CancelId),
                    .run { send in
                        try await mainQueue.sleep(for: .seconds(3))
                        await send(.clearInfo)
                    }
                    .cancellable(id: CancelId, cancelInFlight: true)
                )

            case .scan(let code):
                if uriParser.isValidURI(code.data, zcashSDKEnvironment.network.networkType) {
                    return .send(.found(code))
                } else if let data = uriParser.checkRP(code.data) {
                    return .send(.foundRP(data))
                } else {
                    return .send(.scanFailed(.invalidQRCode))
                }
                
            case .torchPressed:
                do {
                    try captureDevice.torch(!state.isTorchOn)
                    state.isTorchOn.toggle()
                } catch { }
                return .none
            }
        }
    }
}
