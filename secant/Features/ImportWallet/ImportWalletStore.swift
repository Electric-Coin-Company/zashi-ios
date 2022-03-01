//
//  ImportWalletStore.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 02/25/2022.
//

import ComposableArchitecture

typealias ImportWalletStore = Store<ImportWalletState, ImportWalletAction>

struct ImportWalletState: Equatable {
    @BindableState var importedSeedPhrase: String = ""
}

enum ImportWalletAction: Equatable, BindableAction {
    case importRecoveryPhrase
    case importPrivateOrViewingKey
    case binding(BindingAction<ImportWalletState>)
}

struct ImportWalletEnvironment { }

extension ImportWalletEnvironment {
    static let demo = Self()
        
    static let live = Self()
}

typealias ImportWalletReducer = Reducer<ImportWalletState, ImportWalletAction, ImportWalletEnvironment>

extension ImportWalletReducer {
    static let `default` = ImportWalletReducer { _, action, _ in
        switch action {
        case .importRecoveryPhrase:
            // TODO: once connected to SDK, use the state.importedSeedPhrase
            return .none
            
        case .importPrivateOrViewingKey:
            return .none
            
        case .binding:
            return .none
        }
    }
    .binding()
}
