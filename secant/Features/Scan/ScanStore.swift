//
//  ScanUIView.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 16.05.2022.
//

import ComposableArchitecture
import Foundation

typealias ScanReducer = Reducer<ScanState, ScanAction, ScanEnvironment>
typealias ScanStore = Store<ScanState, ScanAction>
typealias ScanViewStore = ViewStore<ScanState, ScanAction>

// MARK: - State

struct ScanState: Equatable {
    enum ScanStatus: Equatable {
        case failed
        case value(String)
        case unknown
    }

    var isTorchAvailable = false
    var isTorchOn = false
    var isValidValue = false
    var scanStatus: ScanStatus = .unknown

    var scannedValue: String? {
        guard case let .value(scannedValue) = scanStatus else {
            return nil
        }
        
        return scannedValue
    }
}

// MARK: - Action

enum ScanAction: Equatable {
    case onAppear
    case onDisappear
    case found(String)
    case scanFailed
    case scan(String)
    case torchPressed
}

// MARK: - Environment

struct ScanEnvironment {
    let captureDevice: WrappedCaptureDevice
    let scheduler: AnySchedulerOf<DispatchQueue>
    let uriParser: WrappedURIParser
}

// MARK: - Reducer

extension ScanReducer {
    private struct CancelId: Hashable {}

    static let `default` = ScanReducer { state, action, environment in
        switch action {
        case .onAppear:
            // reset the values
            state.scanStatus = .unknown
            state.isValidValue = false
            state.isTorchOn = false
            // check the torch availability
            do {
                state.isTorchAvailable = try environment.captureDevice.isTorchAvailable()
            } catch {
                // TODO [#322]: handle torch errors (https://github.com/zcash/secant-ios-wallet/issues/322)
            }
            return .none
        
        case .onDisappear:
            return Effect.cancel(id: CancelId())

        case .found(let code):
            return .none
            
        case .scanFailed:
            state.scanStatus = .failed
            return .none

        case .scan(let code):
            // the logic for the same scanned code is skipped until some new code
            if let prevCode = state.scannedValue, prevCode == code {
                return .none
            }
            state.scanStatus = .value(code)
            state.isValidValue = false
            do {
                if try environment.uriParser.isValidURI(code) {
                    state.isValidValue = true
                    // once valid URI is scanned we want to start the timer to deliver the code
                    // any new code cancels the schedule and fires new one
                    return .concatenate(
                        Effect.cancel(id: CancelId()),
                        Effect(value: .found(code))
                            .delay(for: 1.0, scheduler: environment.scheduler)
                            .eraseToEffect()
                            .cancellable(id: CancelId(), cancelInFlight: true)
                    )
                }
            } catch {
                state.scanStatus = .failed
            }
            return Effect.cancel(id: CancelId())
            
        case .torchPressed:
            do {
                try environment.captureDevice.torch(!state.isTorchOn)
                state.isTorchOn.toggle()
            } catch {
                // TODO [#322]: handle torch errors (https://github.com/zcash/secant-ios-wallet/issues/322)
            }
            return .none
        }
    }
}

// MARK: Placeholders

extension ScanState {
    static var placeholder: Self {
        .init()
    }
}

extension ScanStore {
    static let placeholder = ScanStore(
        initialState: .placeholder,
        reducer: .default,
        environment: ScanEnvironment(
            captureDevice: .real,
            scheduler: DispatchQueue.main.eraseToAnyScheduler(),
            uriParser: .live()
        )
    )
}
