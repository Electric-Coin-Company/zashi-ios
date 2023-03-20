//
//  ScanUIView.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 16.05.2022.
//

import ComposableArchitecture
import Foundation

typealias ScanStore = Store<ScanReducer.State, ScanReducer.Action>
typealias ScanViewStore = ViewStore<ScanReducer.State, ScanReducer.Action>

struct ScanReducer: ReducerProtocol {
    private enum CancelId {}

    struct State: Equatable {
        enum ScanStatus: Equatable {
            case failed
            case value(RedactableString)
            case unknown
        }

        @BindingState var alert: AlertState<ScanReducer.Action>?
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
        case dismissAlert
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
        case .dismissAlert:
            state.alert = nil
            return .none

        case .onAppear:
            // reset the values
            state.scanStatus = .unknown
            state.isTorchOn = false
            // check the torch availability
            do {
                state.isTorchAvailable = try captureDevice.isTorchAvailable()
            } catch {
                // TODO: [#322] Handle error more properly (https://github.com/zcash/secant-ios-wallet/issues/322)
                state.alert = AlertState(
                    title: TextState(L10n.Scan.Alert.CantInitializeCamera.title),
                    message: TextState(L10n.Scan.Alert.CantInitializeCamera.message(error.localizedDescription)),
                    dismissButton: .default(TextState(L10n.General.ok), action: .send(.dismissAlert))
                )
            }
            return .none
        
        case .onDisappear:
            return .cancel(id: CancelId.self)

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
                    EffectTask.cancel(id: CancelId.self),
                    EffectTask(value: .found(code))
                        .delay(for: 1.0, scheduler: mainQueue)
                        .eraseToEffect()
                        .cancellable(id: CancelId.self, cancelInFlight: true)
                )
            } else {
                state.scanStatus = .failed
            }
            return .cancel(id: CancelId.self)
            
        case .torchPressed:
            do {
                try captureDevice.torch(!state.isTorchOn)
                state.isTorchOn.toggle()
            } catch {
                // TODO: [#322] handle torch errors (https://github.com/zcash/secant-ios-wallet/issues/322)
                state.alert = AlertState(
                    title: TextState(L10n.Scan.Alert.CantInitializeCamera.title),
                    message: TextState(L10n.Scan.Alert.CantInitializeCamera.message(error.localizedDescription)),
                    dismissButton: .default(TextState(L10n.General.ok), action: .send(.dismissAlert))
                )
            }
            return .none
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
