//
//  SwapAndPayCoordFlowStore.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-05-14.
//

import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit

import AudioServices
import Models

// Path
import AddressBook
import Scan
import SwapAndPayForm

@Reducer
public struct SwapAndPayCoordFlow {
    @Reducer
    public enum Path {
        case addressBookChainToken(AddressBook)
        case addressBookContact(AddressBook)
        case scan(Scan)
    }
    
    @ObservableState
    public struct State {
        public var isHelpSheetPresented = false
        public var path = StackState<Path.State>()
        public var selectedOperationChip = 0
        public var swapAndPayState = SwapAndPay.State.initial

        public init() { }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<SwapAndPayCoordFlow.State>)
        case helpSheetRequested
        case operationChipTapped(Int)
        case path(StackActionOf<Path>)
        case swapAndPay(SwapAndPay.Action)
    }

    @Dependency(\.audioServices) var audioServices

    public init() { }

    public var body: some Reducer<State, Action> {
        coordinatorReduce()

        BindingReducer()
        
        Scope(state: \.swapAndPayState, action: \.swapAndPay) {
            SwapAndPay()
        }

        Reduce { state, action in
            switch action {
            case .operationChipTapped(let index):
                state.selectedOperationChip = index
                return .send(.swapAndPay(.enableSwapExperience(index == 0)))
                
            case .helpSheetRequested:
                state.isHelpSheetPresented.toggle()
                return .none
                
            default: return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
