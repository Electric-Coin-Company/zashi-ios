//
//  RequestZecStore.swift
//  Zashi
//
//  Created by Lukáš Korba on 09-20-2024.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit
import Pasteboard
import Generated
import Utils
import UIComponents
import ZcashSDKEnvironment

@Reducer
public struct RequestZec {
    @ObservableState
    public struct State: Equatable {
        public var memoState: MessageEditor.State = .initial
        public var requestedZec: Zatoshi = .zero

        public init() {}
    }

    public enum Action: Equatable {
        case memo(MessageEditor.Action)
        case onAppear
        case requestTapped
    }
    
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment
    
    public init() { }

    public var body: some Reducer<State, Action> {
        Scope(state: \.memoState, action: \.memo) {
            MessageEditor()
        }
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.memoState.charLimit = zcashSDKEnvironment.memoCharLimit
                return .none
                
            case .memo:
                return .none
            
            case .requestTapped:
                return .none
            }
        }
    }
}
