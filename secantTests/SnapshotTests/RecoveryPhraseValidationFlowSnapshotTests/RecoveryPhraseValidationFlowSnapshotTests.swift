//
//  RecoveryPhraseValidationFlowSnapshotTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 13.06.2022.
//

import XCTest
@testable import secant_testnet
import ComposableArchitecture

// swiftlint:disable:next type_name
class RecoveryPhraseValidationFlowSnapshotTests: XCTestCase {
    func testRecoveryPhraseValidationFlowPreambleSnapshot() throws {
        let store = RecoveryPhraseValidationFlowStore(
            initialState: .placeholder,
            reducer: RecoveryPhraseValidationFlowReducer()
        )

        addAttachments(RecoveryPhraseValidationFlowView(store: store))
    }

    func testRecoveryPhraseValidationFlowBackupSnapshot() throws {
        let store = RecoveryPhraseValidationFlowStore(
            initialState: .placeholder,
            reducer: RecoveryPhraseValidationFlowReducer()
                .dependency(\.feedbackGenerator, .noOp)
                .dependency(\.mainQueue, DispatchQueue.test.eraseToAnyScheduler())
        )
        let viewStore = ViewStore(store)

        // empty
        addAttachments(
            name: "\(#function)_empty",
            RecoveryPhraseBackupView(store: store)
        )
        
        // 1st chip in place
        viewStore.send(.move(wordChip: .unassigned(word: "thank"), intoGroup: 0))
        addAttachments(
            name: "\(#function)_1stChipInPlace",
            RecoveryPhraseBackupView(store: store)
        )

        // 2nd chip in place
        viewStore.send(.move(wordChip: .unassigned(word: "morning"), intoGroup: 1))
        addAttachments(
            name: "\(#function)_2ndChipInPlace",
            RecoveryPhraseBackupView(store: store)
        )

        // 3rd chip in place
        viewStore.send(.move(wordChip: .unassigned(word: "boil"), intoGroup: 2))
        addAttachments(
            name: "\(#function)_3rdChipInPlace",
            RecoveryPhraseBackupView(store: store)
        )

        // 4th chip in place
        viewStore.send(.move(wordChip: .unassigned(word: "garlic"), intoGroup: 3))
        addAttachments(
            name: "\(#function)_4thChipInPlace",
            RecoveryPhraseBackupView(store: store)
        )
    }
    
    func testRecoveryPhraseValidationFlowSucceededSnapshot() throws {
        let store = RecoveryPhraseValidationFlowStore(
            initialState: .placeholder,
            reducer: RecoveryPhraseValidationFlowReducer()
        )

        addAttachments(RecoveryPhraseBackupSucceededView(store: store))
    }

    func testRecoveryPhraseValidationFlowFailedSnapshot() throws {
        let store = RecoveryPhraseValidationFlowStore(
            initialState: .placeholder,
            reducer: RecoveryPhraseValidationFlowReducer()
        )

        addAttachments(RecoveryPhraseBackupFailedView(store: store))
    }
}
