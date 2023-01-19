//
//  RecoveryPhraseDisplayStore.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 10/26/21.
//

import Foundation
import ComposableArchitecture

typealias RecoveryPhraseDisplayStore = Store<RecoveryPhraseDisplayReducer.State, RecoveryPhraseDisplayReducer.Action>

struct RecoveryPhraseDisplayReducer: ReducerProtocol {
    struct State: Equatable {
        var phrase: RecoveryPhrase?
        var showCopyToBufferAlert = false
    }
    
    enum Action: Equatable {
        case copyToBufferPressed
        case finishedPressed
        case phraseResponse(RecoveryPhrase)
    }
    
    @Dependency(\.pasteboard) var pasteboard

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .copyToBufferPressed:
            guard let phrase = state.phrase?.toString() else { return .none }
            pasteboard.setString(phrase)
            state.showCopyToBufferAlert = true
            return .none
            
        case .finishedPressed:
            // TODO: [#47] remove this when feature is implemented in https://github.com/zcash/secant-ios-wallet/issues/47
            return .none
            
        case let .phraseResponse(phrase):
            state.phrase = phrase
            return .none
        }
    }
}

extension RecoveryPhraseDisplayReducer {
    static let demo = AnyReducer<RecoveryPhraseDisplayReducer.State, RecoveryPhraseDisplayReducer.Action, Void> { _ in
        RecoveryPhraseDisplayReducer()
    }
}
