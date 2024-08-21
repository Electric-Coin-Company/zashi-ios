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
import UserPreferencesStorage
import ZcashSDKEnvironment

@Reducer
public struct ServerSetup {
    let streamingCallTimeoutInMillis = ZcashSDKEnvironment.ZcashSDKConstants.streamingCallTimeoutInMillis
    
    @ObservableState
    public struct State: Equatable {
        @Presents var alert: AlertState<Action>?
        var isUpdatingServer = false
        var initialServer: String
        var network: NetworkType = .mainnet
        var selectedServer: String
        var servers: [ZcashSDKEnvironment.Server]
        var customServer: String
        
        public init(
            isUpdatingServer: Bool = false,
            initialServer: String = "",
            network: NetworkType = .mainnet,
            selectedServer: String = "",
            servers: [ZcashSDKEnvironment.Server] = [],
            customServer: String = ""
        ) {
            self.isUpdatingServer = isUpdatingServer
            self.initialServer = initialServer
            self.network = network
            self.selectedServer = selectedServer
            self.servers = servers
            self.customServer = customServer
        }
    }
    
    public enum Action: Equatable, BindableAction {
        case alert(PresentationAction<Action>)
        case binding(BindingAction<State>)
        case onAppear
        case setServerTapped
        case someServerTapped(ZcashSDKEnvironment.Server)
        case switchFailed(ZcashError)
        case switchSucceeded
    }
    
    public init() {}
    
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment
    @Dependency(\.userStoredPreferences) var userStoredPreferences

    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.network = zcashSDKEnvironment.network.networkType
                state.servers = ZcashSDKEnvironment.servers(for: state.network)
                
                let serverConfig = zcashSDKEnvironment.serverConfig()
                
                if serverConfig.isCustom {
                    state.initialServer = L10n.ServerSetup.custom
                    state.customServer = serverConfig.serverString()
                } else {
                    state.initialServer = serverConfig.serverString()
                }
                state.selectedServer = state.initialServer
                return .none
                
            case .alert(.dismiss):
                state.alert = nil
                return .none

            case .alert:
                return .none

            case .binding:
                return .none
            
            case .setServerTapped:
                guard state.initialServer != state.selectedServer || state.selectedServer == L10n.ServerSetup.custom else {
                    return .none
                }
                
                state.isUpdatingServer = true
                
                // custom server needs to be stored first
                var input = state.selectedServer
                if input == L10n.ServerSetup.custom {
                    input = state.customServer
                }
                
                return .run { [input] send in
                    do {
                        let endpoint = UserPreferencesStorage.ServerConfig.endpoint(
                            for: input,
                            streamingCallTimeoutInMillis: streamingCallTimeoutInMillis
                        )
                        guard let endpoint else {
                            throw ZcashError.synchronizerServerSwitch
                        }
                        try await sdkSynchronizer.switchToEndpoint(endpoint)
                        try await mainQueue.sleep(for: .seconds(1))
                        await send(.switchSucceeded)
                    } catch {
                        await send(.switchFailed(error.toZcashError()))
                    }
                }
                
            case .someServerTapped(let newChange):
                state.selectedServer = newChange.value(for: state.network)
                return .none

            case .switchFailed(let error):
                state.isUpdatingServer = false
                state.alert = AlertState.endpoindSwitchFailed(error)
                return .none
                
            case .switchSucceeded:
                state.isUpdatingServer = false
                state.initialServer = state.selectedServer
                var input = state.selectedServer
                var isCustom = false
                if input == L10n.ServerSetup.custom {
                    input = state.customServer
                    isCustom = true
                }
                return .run { [input, isCustom] send in
                    if let serverConfig = UserPreferencesStorage.ServerConfig.config(
                        for: input,
                        isCustom: isCustom,
                        streamingCallTimeoutInMillis: streamingCallTimeoutInMillis
                    ) {
                        do {
                            try await userStoredPreferences.setServer(serverConfig)
                        } catch UserPreferencesStorage.UserPreferencesStorageError.serverConfig {
                            await send(.switchFailed(ZcashError.unknown(UserPreferencesStorage.UserPreferencesStorageError.serverConfig)))
                        }
                    }
                }
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
