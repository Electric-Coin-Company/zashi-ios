//
//  ImportWalletTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 25.05.2022.
//

import XCTest
@testable import secant_testnet
import ComposableArchitecture

// swiftlint:disable type_body_length
class ImportWalletTests: XCTestCase {
    func testOnAppear() throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: ImportWalletReducer()
        )
        
        store.send(.onAppear) { state in
            state.maxWordsCount = 24
        }
    }
    
    func testWordsCount() throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: ImportWalletReducer()
        ) { dependencies in
            dependencies.mnemonic = .noOp
            dependencies.mnemonic.isValid = { _ in throw "invalid mnemonic" }
        }
        
        let seedPhrase = "one two three".redacted
        store.send(.seedPhraseInputChanged(seedPhrase)) { state in
            state.importedSeedPhrase = seedPhrase
            state.wordsCount = 3
            state.isValidMnemonic = false
        }
    }

    func testMaxWordsInvalidMnemonic() throws {
        let store = TestStore(
            initialState: ImportWalletReducer.State(maxWordsCount: 24),
            reducer: ImportWalletReducer()
        ) { dependencies in
            dependencies.mnemonic = .noOp
            dependencies.mnemonic.isValid = { _ in throw "invalid mnemonic" }
        }

        let seedPhrase = "a a a a a a a a a a a a a a a a a a a a a a a a".redacted
        store.send(.seedPhraseInputChanged(seedPhrase)) { state in
            state.importedSeedPhrase = seedPhrase
            state.wordsCount = 24
            state.isValidNumberOfWords = true
            state.isValidMnemonic = false
        }
    }

    func testValidMnemonic() throws {
        let store = TestStore(
            initialState: ImportWalletReducer.State(maxWordsCount: 24),
            reducer: ImportWalletReducer()
        ) {
            $0.mnemonic = .noOp
        }

        let seedPhrase =
            """
            still champion voice habit trend flight \
            survey between bitter process artefact blind \
            carbon truly provide dizzy crush flush \
            breeze blouse charge solid fish spread
            """.redacted
        store.send(.seedPhraseInputChanged(seedPhrase)) { state in
            state.importedSeedPhrase = seedPhrase
            state.wordsCount = 24
            state.isValidNumberOfWords = true
            state.isValidMnemonic = true
        }
    }
    
    func testInvalidBirthdayHeight_lessThanDefault() throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: ImportWalletReducer()
        )
        
        let birthday = "1600000".redacted
        store.send(.birthdayInputChanged(birthday)) { state in
            state.birthdayHeight = birthday
        }
    }

    func testInvalidBirthdayHeight_invalidInput() throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: ImportWalletReducer()
        )
        
        let birthday = "abc".redacted
        store.send(.birthdayInputChanged(birthday)) { state in
            state.birthdayHeight = birthday
        }
    }

    func testInvalidBirthdayHeight_validInput() throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: ImportWalletReducer()
        )
        
        let birthday = "1700000".redacted
        store.send(.birthdayInputChanged(birthday)) { state in
            state.birthdayHeight = birthday
            state.birthdayHeightValue = RedactableBlockHeight(1_700_000)
        }
    }
    
    func testDismissAlert() throws {
        let store = TestStore(
            initialState:
                ImportWalletReducer.State(
                    alert: AlertState(
                        title: TextState("Success"),
                        message: TextState("The wallet has been successfully recovered."),
                        dismissButton: .default(
                            TextState("Ok"),
                            action: .send(.successfullyRecovered)
                        )
                    )
                ),
            reducer: ImportWalletReducer()
        )
        
        store.send(.dismissAlert) { state in
            state.alert = nil
        }
    }
    
    func testFormValidity_validBirthday_invalidMnemonic() throws {
        let store = TestStore(
            initialState: ImportWalletReducer.State(maxWordsCount: 24),
            reducer: ImportWalletReducer()
        ) { dependencies in
            dependencies.mnemonic = .noOp
            dependencies.mnemonic.isValid = { _ in throw "invalid mnemonic" }
        }
        
        let birthday = "1700000".redacted
        store.send(.birthdayInputChanged(birthday)) { state in
            state.birthdayHeight = birthday
            state.birthdayHeightValue = RedactableBlockHeight(1_700_000)
        }
        
        let seedPhrase = "a a a a a a a a a a a a a a a a a a a a a a a a".redacted
        store.send(.seedPhraseInputChanged(seedPhrase)) { state in
            state.importedSeedPhrase = seedPhrase
            state.wordsCount = 24
            state.isValidNumberOfWords = true
            state.isValidMnemonic = false
            XCTAssertFalse(
                state.isValidForm,
                "Import Wallet tests: `testFormValidity_validBirthday_validMnemonic` is expected to be false but it is \(state.isValidForm)"
            )
        }
    }
    
    func testFormValidity_invalidBirthday_invalidMnemonic() throws {
        let store = TestStore(
            initialState: ImportWalletReducer.State(maxWordsCount: 24),
            reducer: ImportWalletReducer()
        ) { dependencies in
            dependencies.mnemonic = .noOp
            dependencies.mnemonic.isValid = { _ in throw "invalid mnemonic" }
        }

        let birthday = "1600000".redacted
        store.send(.birthdayInputChanged(birthday)) { state in
            state.birthdayHeight = birthday
        }
        
        let seedPhrase = "a a a a a a a a a a a a a a a a a a a a a a a a".redacted
        store.send(.seedPhraseInputChanged(seedPhrase)) { state in
            state.importedSeedPhrase = seedPhrase
            state.wordsCount = 24
            state.isValidNumberOfWords = true
            state.isValidMnemonic = false
            XCTAssertFalse(
                state.isValidForm,
                "Import Wallet tests: `testFormValidity_validBirthday_validMnemonic` is expected to be false but it is \(state.isValidForm)"
            )
        }
    }
    
    func testFormValidity_invalidBirthday_validMnemonic() throws {
        let store = TestStore(
            initialState: ImportWalletReducer.State(maxWordsCount: 24),
            reducer: ImportWalletReducer()
        ) {
            $0.mnemonic = .noOp
        }

        let birthday = "1600000".redacted
        store.send(.birthdayInputChanged(birthday)) { state in
            state.birthdayHeight = birthday
        }
        
        let seedPhrase =
            """
            still champion voice habit trend flight \
            survey between bitter process artefact blind \
            carbon truly provide dizzy crush flush \
            breeze blouse charge solid fish spread
            """.redacted
        store.send(.seedPhraseInputChanged(seedPhrase)) { state in
            state.importedSeedPhrase = seedPhrase
            state.wordsCount = 24
            state.isValidNumberOfWords = true
            state.isValidMnemonic = true
            XCTAssertFalse(
                state.isValidForm,
                "Import Wallet tests: `testFormValidity_validBirthday_validMnemonic` is expected to be false but it is \(state.isValidForm)"
            )
        }
    }
    
    func testFormValidity_validBirthday_validMnemonic() throws {
        let store = TestStore(
            initialState: ImportWalletReducer.State(maxWordsCount: 24),
            reducer: ImportWalletReducer()
        ) {
            $0.mnemonic = .noOp
        }

        let birthday = "1700000".redacted
        store.send(.birthdayInputChanged(birthday)) { state in
            state.birthdayHeight = birthday
            state.birthdayHeightValue = RedactableBlockHeight(1_700_000)
        }
        
        let seedPhrase =
            """
            still champion voice habit trend flight \
            survey between bitter process artefact blind \
            carbon truly provide dizzy crush flush \
            breeze blouse charge solid fish spread
            """.redacted
        store.send(.seedPhraseInputChanged(seedPhrase)) { state in
            state.importedSeedPhrase = seedPhrase
            state.wordsCount = 24
            state.isValidNumberOfWords = true
            state.isValidMnemonic = true
            XCTAssertTrue(
                state.isValidForm,
                "Import Wallet tests: `testFormValidity_validBirthday_validMnemonic` is expected to be true but it is \(state.isValidForm)"
            )
        }
    }
    
    func testFormValidity_noBirthday_validMnemonic() throws {
        let store = TestStore(
            initialState: ImportWalletReducer.State(maxWordsCount: 24),
            reducer: ImportWalletReducer()
        ) {
            $0.mnemonic = .noOp
        }

        let seedPhrase =
            """
            still champion voice habit trend flight \
            survey between bitter process artefact blind \
            carbon truly provide dizzy crush flush \
            breeze blouse charge solid fish spread
            """.redacted
        store.send(.seedPhraseInputChanged(seedPhrase)) { state in
            state.importedSeedPhrase = seedPhrase
            state.wordsCount = 24
            state.isValidNumberOfWords = true
            state.isValidMnemonic = true
            XCTAssertTrue(
                state.isValidForm,
                "Import Wallet tests: `testFormValidity_validBirthday_validMnemonic` is expected to be true but it is \(state.isValidForm)"
            )
        }
    }

    func testRestoreWallet() throws {
        let store = TestStore(
            initialState: ImportWalletReducer.State(
                alert: nil,
                birthdayHeight: "1700000".redacted,
                birthdayHeightValue: RedactableBlockHeight(1_700_000),
                importedSeedPhrase: """
                still champion voice habit trend flight \
                survey between bitter process artefact blind \
                carbon truly provide dizzy crush flush \
                breeze blouse charge solid fish spread
                """.redacted,
                isValidMnemonic: true,
                isValidNumberOfWords: true,
                maxWordsCount: 24,
                wordsCount: 24
            ),
            reducer: ImportWalletReducer()
        ) { dependencies in
            dependencies.mnemonic = .noOp
            dependencies.walletStorage = .noOp
        }
        
        store.send(.restoreWallet) { state in
            state.alert = AlertState(
                title: TextState("Success"),
                message: TextState("The wallet has been successfully recovered."),
                dismissButton: .default(
                    TextState("Ok"),
                    action: .send(.successfullyRecovered)
                )
            )
        }
        
        store.receive(.initializeSDK)
    }
}
