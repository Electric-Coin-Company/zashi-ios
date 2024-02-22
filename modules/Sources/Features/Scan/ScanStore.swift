//
//  ScanStore.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 16.05.2022.
//

import ComposableArchitecture
import Foundation
import CaptureDevice
import Utils
import URIParser
import ZcashLightClientKit
import Generated
import ZcashSDKEnvironment

@Reducer
public struct Scan {
    private enum CancelId { case timer }

    @ObservableState
    public struct State: Equatable {
        public var info = ""
        public var isTorchAvailable = false
        public var isTorchOn = false

        public init(
            info: String = "",
            isTorchAvailable: Bool = false,
            isTorchOn: Bool = false
        ) {
            self.info = info
            self.isTorchAvailable = isTorchAvailable
            self.isTorchOn = isTorchOn
        }
    }

    @Dependency(\.captureDevice) var captureDevice
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.uriParser) var uriParser
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    public enum Action: Equatable {
        case cancelPressed
        case clearInfo
        case onAppear
        case onDisappear
        case found(RedactableString)
        case scanFailed
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
                    state.info = L10n.Scan.cameraSettings
                }
                return .none
                
            case .onDisappear:
                return .cancel(id: CancelId.timer)
                
            case .cancelPressed:
                return .none
                
            case .clearInfo:
                state.info = ""
                return .cancel(id: CancelId.timer)

            case .found:
                return .none

            case .scanFailed:
                state.info = L10n.Scan.invalidQR
                return .concatenate(
                    Effect.cancel(id: CancelId.timer),
                    .run { send in
                        try await mainQueue.sleep(for: .seconds(3))
                        await send(.clearInfo)
                    }
                    .cancellable(id: CancelId.timer, cancelInFlight: true)
                )

            case .scan(let code):
                if uriParser.isValidURI(code.data, zcashSDKEnvironment.network.networkType) {
                    return .send(.found(code))
                } else {
                    return .send(.scanFailed)
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
