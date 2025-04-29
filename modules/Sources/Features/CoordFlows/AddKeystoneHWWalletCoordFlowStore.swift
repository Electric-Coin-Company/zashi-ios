//
//  AddKeystoneHWWalletCoordFlowStore.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-03-19.
//

import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit

import AudioServices

// Path
import AddKeystoneHWWallet
import Scan

@Reducer
public struct AddKeystoneHWWalletCoordFlow {
    @Reducer
    public enum Path {
        case accountHWWalletSelection(AddKeystoneHWWallet)
        case scan(Scan)
    }
    
    @ObservableState
    public struct State {
        public var addKeystoneHWWalletState = AddKeystoneHWWallet.State.initial
        public var path = StackState<Path.State>()

        public init() { }
    }

    public enum Action {
        case addKeystoneHWWallet(AddKeystoneHWWallet.Action)
        case path(StackActionOf<Path>)
    }

    @Dependency(\.audioServices) var audioServices
    
    public init() { }

    public var body: some Reducer<State, Action> {
        coordinatorReduce()

        Scope(state: \.addKeystoneHWWalletState, action: \.addKeystoneHWWallet) {
            AddKeystoneHWWallet()
        }
        
        Reduce { state, action in
            switch action {
            default: return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
