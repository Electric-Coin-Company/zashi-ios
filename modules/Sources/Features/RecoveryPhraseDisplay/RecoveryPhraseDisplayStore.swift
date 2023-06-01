//
//  RecoveryPhraseDisplayStore.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 10/26/21.
//

import Foundation
import ComposableArchitecture
import Models
import Pasteboard

public typealias RecoveryPhraseDisplayStore = Store<RecoveryPhraseDisplayReducer.State, RecoveryPhraseDisplayReducer.Action>

public struct RecoveryPhraseDisplayReducer: ReducerProtocol {
    public struct State: Equatable {
        public var phrase: RecoveryPhrase?
        public var showCopyToBufferAlert = false
        
        public init(phrase: RecoveryPhrase? = nil, showCopyToBufferAlert: Bool = false) {
            self.phrase = phrase
            self.showCopyToBufferAlert = showCopyToBufferAlert
        }
    }
    
    public enum Action: Equatable {
        case copyToBufferPressed
        case finishedPressed
        case phraseResponse(RecoveryPhrase)
    }
    
    @Dependency(\.pasteboard) var pasteboard

    public init() {}
    
    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .copyToBufferPressed:
            guard let phrase = state.phrase?.toString() else { return .none }
            pasteboard.setString(phrase)
            state.showCopyToBufferAlert = true
            return .none
            
        case .finishedPressed:
            return .none
            
        case let .phraseResponse(phrase):
            state.phrase = phrase
            return .none
        }
    }
}

extension RecoveryPhraseDisplayReducer {
    public static let demo = AnyReducer<RecoveryPhraseDisplayReducer.State, RecoveryPhraseDisplayReducer.Action, Void> { _ in
        RecoveryPhraseDisplayReducer()
    }
}
