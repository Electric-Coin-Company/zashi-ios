//
//  ServerSetup.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 2024-02-07.
//

import Foundation
import ComposableArchitecture
import ZcashLightClientKit

import Generated
import SDKSynchronizer
import ZcashSDKEnvironment

@Reducer
public struct ServerSetup {
    let udKey = ZcashSDKEnvironment.Servers.Constants.udServerKey
    let udCustomServerKey = ZcashSDKEnvironment.Servers.Constants.udCustomServerKey

    @ObservableState
    public struct State: Equatable {
        @Presents var alert: AlertState<Action>?
        var isUpdatingServer = false
        var initialServer: ZcashSDKEnvironment.Servers = .mainnet
        var server: ZcashSDKEnvironment.Servers = .mainnet
        var customServer: String
        
        public init(
            isUpdatingServer: Bool = false,
            server: ZcashSDKEnvironment.Servers = .mainnet,
            customServer: String = ""
        ) {
            self.isUpdatingServer = isUpdatingServer
            self.server = server
            self.customServer = customServer
        }
    }
    
    public enum Action: Equatable, BindableAction {
        case alert(PresentationAction<Action>)
        case binding(BindingAction<State>)
        case onAppear
        case setServerTapped
        case someServerTapped(ZcashSDKEnvironment.Servers)
        case switchFailed(ZcashError)
        case switchSucceeded
    }
    
    public init() {}
    
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.userDefaults) var userDefaults

    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard let storedServerRaw = userDefaults.objectForKey(udKey) as? String, let storedServer = ZcashSDKEnvironment.Servers(rawValue: storedServerRaw) else {
                    return .none
                }
                if let storedCustomServerRaw = userDefaults.objectForKey(udCustomServerKey) as? String {
                    state.customServer = storedCustomServerRaw
                }
                state.server = storedServer
                state.initialServer = storedServer
                return .none
                
            case .alert(.dismiss):
                state.alert = nil
                return .none

            case .alert:
                return .none

            case .binding:
                return .none
            
            case .setServerTapped:
                guard state.initialServer != state.server || state.server == .custom else {
                    return .none
                }
                
                state.isUpdatingServer = true
                
                // custom server needs to be stored first
                if state.server == .custom {
                    userDefaults.setValue(state.customServer, udCustomServerKey)
                }
                
                return .run { [server = state.server] send in
                    do {
                        guard let lightWalletEndpoint = server.lightWalletEndpoint(userDefaults) else {
                            throw ZcashError.synchronizerServerSwitch
                        }
                        try await sdkSynchronizer.switchToEndpoint(lightWalletEndpoint)
                        try await mainQueue.sleep(for: .seconds(1))
                        await send(.switchSucceeded)
                    } catch {
                        await send(.switchFailed(error.toZcashError()))
                    }
                }
                
            case .someServerTapped(let newChange):
                state.server = newChange
                return .none

            case .switchFailed(let error):
                state.isUpdatingServer = false
                userDefaults.remove(udCustomServerKey)
                state.alert = AlertState.endpoindSwitchFailed(error)
                return .none
                
            case .switchSucceeded:
                userDefaults.setValue(state.server.rawValue, udKey)
                state.isUpdatingServer = false
                state.initialServer = state.server
                if state.server != .custom {
                    userDefaults.remove(udCustomServerKey)
                    state.customServer = ""
                }
                return .none
            }
        }
    }
}

// MARK: Alerts

extension AlertState where Action == ServerSetup.Action {
    public static func endpoindSwitchFailed(_ error: ZcashError) -> AlertState {
        AlertState {
            TextState(L10n.ServerSetup.Alert.Failed.title)
        } actions: {
            ButtonState(action: .alert(.dismiss)) {
                TextState(L10n.General.ok)
            }
        } message: {
            TextState(L10n.ServerSetup.Alert.Failed.message(error.detailedMessage))
        }
    }
}
