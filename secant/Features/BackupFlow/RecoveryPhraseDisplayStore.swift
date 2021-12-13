//
//  RecoveryPhraseDisplayStore.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 10/26/21.
//

import Foundation
import ComposableArchitecture
import UIKit

enum RecoveryPhraseError: Error {
    /// This error is thrown then the Recovery Phrase can't be generated
    case unableToGeneratePhrase
}

struct Pasteboard {
    let setString: (String) -> Void
    let getString: () -> String?
}

extension Pasteboard {
    private struct TestPasteboard {
        static var general = TestPasteboard()
        var string: String?
    }
    
    static let live = Pasteboard(
        setString: { UIPasteboard.general.string = $0 },
        getString: { UIPasteboard.general.string }
    )
    
    static let test = Pasteboard(
        setString: { TestPasteboard.general.string = $0 },
        getString: { TestPasteboard.general.string }
    )
}

struct BackupPhraseEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let newPhrase: () -> Effect<RecoveryPhrase, RecoveryPhraseError>
    let pasteboard: Pasteboard
}

extension BackupPhraseEnvironment {
    private struct DemoPasteboard {
        static var general = Self()
        var string: String?
    }

    static let demo = Self(
        mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
        newPhrase: { Effect(value: .init(words: RecoveryPhrase.placeholder.words)) },
        pasteboard: .test
    )
        
    static let live = Self(
        mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
        newPhrase: { Effect(value: .init(words: RecoveryPhrase.placeholder.words)) },
        pasteboard: .live
    )
}

typealias RecoveryPhraseDisplayStore = Store<RecoveryPhraseDisplayState, RecoveryPhraseDisplayAction>

struct RecoveryPhrase: Equatable {
    struct Group: Hashable {
        var startIndex: Int
        var words: [String]
    }

    let words: [String]
    
    private let groupSize = 6

    func toGroups() -> [Group] {
        let chunks = words.count / groupSize
        return zip(0 ..< chunks, words.chunked(into: groupSize)).map {
            Group(startIndex: $0 * groupSize + 1, words: $1)
        }
    }

    func toString() -> String {
        words.joined(separator: " ")
    }

    func words(fromMissingIndices indices: [Int]) -> [PhraseChip.Kind] {
        assert((indices.count - 1) * groupSize <= self.words.count)

        return indices.enumerated().map { index, position in
            .unassigned(word: self.words[(index * groupSize) + position])
        }
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
    case phraseResponse(Result<RecoveryPhrase, RecoveryPhraseError>)
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
            environment.pasteboard.setString(phrase)
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
