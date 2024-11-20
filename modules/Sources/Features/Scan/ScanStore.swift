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
import URIParser
import ZcashLightClientKit
import Generated
import ZcashSDKEnvironment
import Models
import ZcashPaymentURI
import KeystoneHandler
import KeystoneSDK

@Reducer
public struct Scan {
    public enum ScanImageResult: Equatable {
        case invalidQRCode
        case noQRCodeFound
        case severalQRCodesFound
    }
    
    @ObservableState
    public struct State: Equatable {
        public var cancelId = UUID()
        
        public var info = ""
        public var isCameraEnabled = true
        public var isTorchAvailable = false
        public var isTorchOn = false
        public var isRPFound = false

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
    @Dependency(\.keystoneHandler) var keystoneHandler
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
                state.isRPFound = false
                // check the torch availability
                state.isTorchAvailable = captureDevice.isTorchAvailable()
                if !captureDevice.isAuthorized() {
                    state.isCameraEnabled = false
                    state.info = L10n.Scan.cameraSettings
                }
                return .none
                
            case .onDisappear:
                return .cancel(id: state.cancelId)
                
            case .foundRP:
                return .none

            case .cancelPressed:
                return .none
                
            case .clearInfo:
                state.info = ""
                return .cancel(id: state.cancelId)

            case .found:
                return .none

            case .libraryImage(let image):
                guard !state.isRPFound else {
                    return .none
                }

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
                } else if let data = uriParser.checkRP(code) {
                    state.isRPFound = true
                    return .send(.foundRP(data))
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
                    Effect.cancel(id: state.cancelId),
                    .run { send in
                        try await mainQueue.sleep(for: .seconds(1))
                        await send(.clearInfo)
                    }
                    .cancellable(id: state.cancelId, cancelInFlight: true)
                )

            case .scan(let code):
                guard !state.isRPFound else {
                    return .none
                }
                if uriParser.isValidURI(code.data, zcashSDKEnvironment.network.networkType) {
                    return .send(.found(code))
                } else if let data = uriParser.checkRP(code.data) {
                    state.isRPFound = true
                    return .send(.foundRP(data))
                } else {
                    do {
                        if let result = keystoneHandler.decodeQR(code.data) {
                            print("__LD ==============> progress: \(result.progress)")
                            
                            if let resultUR = result.ur, result.progress == 100 {
                                let scanResult = try KeystoneSDK().cosmos.parseSignature(ur: resultUR)
                                print("__LD scanResult \(scanResult)")
                                // CosmosSignature here to report as found
                            }
                        }
                        
                        return .none
                    } catch {
                        return .send(.scanFailed(.invalidQRCode))
                    }
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
