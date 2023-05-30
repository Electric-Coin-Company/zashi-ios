//
//  ScanUIView.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 16.05.2022.
//

import ComposableArchitecture
import Foundation
import CaptureDeviceClient
import Utils

typealias ScanStore = Store<ScanReducer.State, ScanReducer.Action>
typealias ScanViewStore = ViewStore<ScanReducer.State, ScanReducer.Action>

struct ScanReducer: ReducerProtocol {
    private enum CancelId { case timer }

    struct State: Equatable {
        enum ScanStatus: Equatable {
            case failed
            case value(RedactableString)
            case unknown
        }

        var isTorchAvailable = false
        var isTorchOn = false
        var scanStatus: ScanStatus = .unknown

        var scannedValue: String? {
            guard case let .value(scannedValue) = scanStatus else {
                return nil
            }
            
            return scannedValue.data
        }
        
        var isValidValue: Bool {
            if case .value = scanStatus {
                return true
            }
            return false
        }
    }

    @Dependency(\.captureDevice) var captureDevice
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.uriParser) var uriParser

    enum Action: Equatable {
        case alert(AlertRequest)
        case onAppear
        case onDisappear
        case found(RedactableString)
        case scanFailed
        case scan(RedactableString)
        case torchPressed
    }
    
    // swiftlint:disable:next cyclomatic_complexity
    func reduce(into state: inout State, action: Action) -> ComposableArchitecture.EffectTask<Action> {
        switch action {
        case .alert:
            return .none

        case .onAppear:
            // reset the values
            state.scanStatus = .unknown
            state.isTorchOn = false
            // check the torch availability
            do {
                state.isTorchAvailable = try captureDevice.isTorchAvailable()
                return .none
            } catch {
                return EffectTask(value: .alert(.scan(.cantInitializeCamera(error.toZcashError()))))
            }
        
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
            if uriParser.isValidURI(code.data) {
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
                return .none
            } catch {
                return EffectTask(value: .alert(.scan(.cantInitializeCamera(error.toZcashError()))))
            }
        }
    }
}

// MARK: Placeholders

extension ScanReducer.State {
    static var placeholder: Self {
        .init()
    }
}

extension ScanStore {
    static let placeholder = ScanStore(
        initialState: .placeholder,
        reducer: ScanReducer()
    )
}
