//
//  RecoveryPhraseDisplayStore.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 10/26/21.
//

import Foundation
import ComposableArchitecture

struct BackupPhraseEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var newPhrase: () -> Effect<RecoveryPhrase, AppError>
}

struct RecoveryPhrase: Equatable {
    struct Chunk {
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
}

struct BackupPhraseState: Equatable {
    var phrase: RecoveryPhrase?
}

enum BackupPhraseAction: Equatable {
    case createPhrase
    case copyToBufferPressed
    case finishedPressed
    case phraseResponse(Result<RecoveryPhrase, AppError>)
}

let backupFlowReducer = Reducer<BackupPhraseState, BackupPhraseAction, BackupPhraseEnvironment> { state, action, environment in
    switch action {
    case .createPhrase:
        return environment.newPhrase()
            .receive(on: environment.mainQueue)
            .catchToEffect(BackupPhraseAction.phraseResponse)
    case .copyToBufferPressed:
        dump("not implemented")
        return .none
    case .finishedPressed:
        dump("not implemented")
        return .none
    case let .phraseResponse(.success(phrase)):
        state.phrase = phrase
        return .none
    case .phraseResponse(.failure):
        dump("not implemented")
        return .none
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
