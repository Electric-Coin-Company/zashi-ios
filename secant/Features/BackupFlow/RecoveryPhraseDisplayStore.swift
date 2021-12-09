//
//  RecoveryPhraseDisplayStore.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 10/26/21.
//

import Foundation
import ComposableArchitecture
import UIKit

struct BackupPhraseEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var newPhrase: () -> Effect<RecoveryPhrase, AppError>
    var pasteboard: UIPasteboard = .general
}

typealias RecoveryPhraseDisplayStore = Store<RecoveryPhraseDisplayState, RecoveryPhraseDisplayAction>

struct RecoveryPhrase: Equatable {
    struct Chunk: Hashable {
        var startIndex: Int
        var words: [String]
    }

    private let chunkSize = 6

    let words: [String]

    func toChunks() -> [Chunk] {
        let chunks = words.count / chunkSize
        return zip(0 ..< chunks, words.chunked(into: chunkSize)).map {
            Chunk(startIndex: $0 * chunkSize + 1, words: $1)
        }
    }

    func toString() -> String {
        words.joined(separator: " ")
    }
}

struct RecoveryPhraseDisplayState: Equatable {
    var phrase: RecoveryPhrase?
    var showCopyToBufferAlert = false
}

enum RecoveryPhraseDisplayAction: Equatable {
    case createPhrase
    case copyToBufferPressed
    case finishedPressed
    case phraseResponse(Result<RecoveryPhrase, AppError>)
}

typealias RecoveryPhraseDisplayReducer = Reducer<RecoveryPhraseDisplayState, RecoveryPhraseDisplayAction, BackupPhraseEnvironment>

extension RecoveryPhraseDisplayReducer {
    static let `default` = RecoveryPhraseDisplayReducer { state, action, environment in
        switch action {
        case .createPhrase:
            return environment.newPhrase()
                .receive(on: environment.mainQueue)
                .catchToEffect(RecoveryPhraseDisplayAction.phraseResponse)
        case .copyToBufferPressed:
            guard let phrase = state.phrase?.toString() else { return .none }
            environment.pasteboard.string = phrase
            state.showCopyToBufferAlert = true
            return .none
        case .finishedPressed:
            // TODO: remove this when feature is implemented in https://github.com/zcash/secant-ios-wallet/issues/47
            return .none
        case let .phraseResponse(.success(phrase)):
            state.phrase = phrase
            return .none
        case .phraseResponse(.failure):
            // TODO: remove this when feature is implemented in https://github.com/zcash/secant-ios-wallet/issues/129
            return .none
        }
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
