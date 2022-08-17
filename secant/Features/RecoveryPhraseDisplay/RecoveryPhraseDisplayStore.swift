//
//  RecoveryPhraseDisplayStore.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 10/26/21.
//

import Foundation
import ComposableArchitecture

typealias RecoveryPhraseDisplayReducer = Reducer<RecoveryPhraseDisplayState, RecoveryPhraseDisplayAction, RecoveryPhraseDisplayEnvironment>
typealias RecoveryPhraseDisplayStore = Store<RecoveryPhraseDisplayState, RecoveryPhraseDisplayAction>
typealias RecoveryPhraseDisplayViewStore = ViewStore<RecoveryPhraseDisplayState, RecoveryPhraseDisplayAction>

// MARK: - State

struct RecoveryPhraseDisplayState: Equatable {
    var phrase: RecoveryPhrase?
    var showCopyToBufferAlert = false
}

// MARK: - Action

enum RecoveryPhraseDisplayAction: Equatable {
    case createPhrase
    case copyToBufferPressed
    case finishedPressed
    case phraseResponse(RecoveryPhrase)
}

// MARK: - Environment

struct RecoveryPhraseDisplayEnvironment {
    let scheduler: AnySchedulerOf<DispatchQueue>
    let newPhrase: () async throws -> RecoveryPhrase
    let pasteboard: WrappedPasteboard
    let feedbackGenerator: WrappedFeedbackGenerator
}

extension RecoveryPhraseDisplayEnvironment {
    static let demo = Self(
        scheduler: DispatchQueue.main.eraseToAnyScheduler(),
        newPhrase: { .init(words: RecoveryPhrase.placeholder.words) },
        pasteboard: .test,
        feedbackGenerator: .silent
    )
}

// MARK: - Reducer

extension RecoveryPhraseDisplayReducer {
    static let `default` = RecoveryPhraseDisplayReducer { state, action, environment in
        switch action {
        case .createPhrase:
            return .run { send in
                do {
                    await send(.phraseResponse(try await environment.newPhrase()))
                } catch {
                    // TODO: remove this when feature is implemented in https://github.com/zcash/secant-ios-wallet/issues/129
                }
            }
            
        case .copyToBufferPressed:
            guard let phrase = state.phrase?.toString() else { return .none }
            environment.pasteboard.setString(phrase)
            state.showCopyToBufferAlert = true
            return .none
            
        case .finishedPressed:
            // TODO: remove this when feature is implemented in https://github.com/zcash/secant-ios-wallet/issues/47
            return .none
            
        case let .phraseResponse(phrase):
            state.phrase = phrase
            return .none
        }
    }
}
