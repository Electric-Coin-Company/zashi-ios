//
//  ScanUIView.swift
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

public typealias ScanStore = Store<ScanReducer.State, ScanReducer.Action>
public typealias ScanViewStore = ViewStore<ScanReducer.State, ScanReducer.Action>

public struct ScanReducer: ReducerProtocol {
    private enum CancelId { case timer }
    let networkType: NetworkType

    public struct State: Equatable {
        public enum ScanStatus: Equatable {
            case failed
            case value(RedactableString)
            case unknown
        }

        @PresentationState public var alert: AlertState<Action>?
        public var isTorchAvailable = false
        public var isTorchOn = false
        public var scanStatus: ScanStatus = .unknown

        public var scannedValue: String? {
            guard case let .value(scannedValue) = scanStatus else {
                return nil
            }
            
            return scannedValue.data
        }
        
        public var isValidValue: Bool {
            if case .value = scanStatus {
                return true
            }
            return false
        }
        
        public init(
            isTorchAvailable: Bool = false,
            isTorchOn: Bool = false,
            scanStatus: ScanStatus = .unknown
        ) {
            self.isTorchAvailable = isTorchAvailable
            self.isTorchOn = isTorchOn
            self.scanStatus = scanStatus
        }
    }

    @Dependency(\.captureDevice) var captureDevice
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.uriParser) var uriParser

    public enum Action: Equatable {
        case alert(PresentationAction<Action>)
        case onAppear
        case onDisappear
        case found(RedactableString)
        case scanFailed
        case scan(RedactableString)
        case torchPressed
    }
    
    public init(networkType: NetworkType) {
        self.networkType = networkType
    }

    // swiftlint:disable:next cyclomatic_complexity
    public var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .alert(.presented(let action)):
                return EffectTask(value: action)

            case .alert(.dismiss):
                state.alert = nil
                return .none

            case .alert:
                return .none
                
            case .onAppear:
                // reset the values
                state.scanStatus = .unknown
                state.isTorchOn = false
                // check the torch availability
                do {
                    state.isTorchAvailable = try captureDevice.isTorchAvailable()
                } catch {
                    state.alert = AlertState.cantInitializeCamera(error.toZcashError())
                }
                return .none
                
            case .onDisappear:
                return .cancel(id: CancelId.timer)
                
            case .found:
                return .none
                
            case .scanFailed:
                state.scanStatus = .failed
                return .none
                
            case .scan(let code):
                // the logic for the same scanned code is skipped until some new code
                if let prevCode = state.scannedValue, prevCode == code.data {
                    return .none
                }
                if uriParser.isValidURI(code.data, networkType) {
                    state.scanStatus = .value(code)
                    // once valid URI is scanned we want to start the timer to deliver the code
                    // any new code cancels the schedule and fires new one
                    return .concatenate(
                        EffectTask.cancel(id: CancelId.timer),
                        EffectTask(value: .found(code))
                            .delay(for: 1.0, scheduler: mainQueue)
                            .eraseToEffect()
                            .cancellable(id: CancelId.timer, cancelInFlight: true)
                    )
                } else {
                    state.scanStatus = .failed
                }
                return .cancel(id: CancelId.timer)
                
            case .torchPressed:
                do {
                    try captureDevice.torch(!state.isTorchOn)
                    state.isTorchOn.toggle()
                } catch {
                    state.alert = AlertState.cantInitializeCamera(error.toZcashError())
                }
                return .none
            }
        }
        .ifLet(\.$alert, action: /Action.alert)
    }
}

// MARK: Alerts

extension AlertState where Action == ScanReducer.Action {
    public static func cantInitializeCamera(_ error: ZcashError) -> AlertState {
        AlertState {
            TextState(L10n.Scan.Alert.CantInitializeCamera.title)
        } message: {
            TextState(L10n.Scan.Alert.CantInitializeCamera.message(error.message, error.code.rawValue))
        }
    }
}

// MARK: Placeholders

extension ScanReducer.State {
    public static var placeholder: Self {
        .init()
    }
}

extension ScanStore {
    public static let placeholder = ScanStore(
        initialState: .placeholder,
        reducer: ScanReducer(networkType: .testnet)
    )
}
