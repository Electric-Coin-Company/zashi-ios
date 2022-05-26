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
        let testEnvironment = ImportWalletEnvironment(
            mnemonic: .mock,
            walletStorage: .throwing,
            zcashSDKEnvironment: .testnet
        )

        let store = TestStore(
            initialState: .placeholder,
            reducer: ImportWalletReducer.default,
            environment: testEnvironment
        )
        
        store.send(.onAppear) { state in
            state.maxWordsCount = 24
        }
    }
    
    func testWordsCount() throws {
        let testEnvironment = ImportWalletEnvironment(
            mnemonic: .live,
            walletStorage: .throwing,
            zcashSDKEnvironment: .testnet
        )

        let store = TestStore(
            initialState: .placeholder,
            reducer: ImportWalletReducer.default,
            environment: testEnvironment
        )
        
        store.send(.binding(.set(\.$importedSeedPhrase, "one two three"))) { state in
            state.importedSeedPhrase = "one two three"
            state.wordsCount = 3
            state.isValidMnemonic = false
        }
    }

    func testMaxWordsInvalidMnemonic() throws {
        let testEnvironment = ImportWalletEnvironment(
            mnemonic: .live,
            walletStorage: .throwing,
            zcashSDKEnvironment: .testnet
        )

        let store = TestStore(
            initialState: ImportWalletState(maxWordsCount: 24),
            reducer: ImportWalletReducer.default,
            environment: testEnvironment
        )
        
        store.send(.binding(.set(\.$importedSeedPhrase, "a a a a a a a a a a a a a a a a a a a a a a a a"))) { state in
            state.importedSeedPhrase = "a a a a a a a a a a a a a a a a a a a a a a a a"
            state.wordsCount = 24
            state.isValidNumberOfWords = true
            state.isValidMnemonic = false
        }
    }

    func testValidMnemonic() throws {
        let testEnvironment = ImportWalletEnvironment(
            mnemonic: .live,
            walletStorage: .throwing,
            zcashSDKEnvironment: .testnet
        )

        let store = TestStore(
            initialState: ImportWalletState(maxWordsCount: 24),
            reducer: ImportWalletReducer.default,
            environment: testEnvironment
        )
        
        store.send(
            .binding(
                .set(
                    \.$importedSeedPhrase,
            """
            still champion voice habit trend flight \
            survey between bitter process artefact blind \
            carbon truly provide dizzy crush flush \
            breeze blouse charge solid fish spread
            """
                )
            )
        ) { state in
            state.importedSeedPhrase = """
            still champion voice habit trend flight \
            survey between bitter process artefact blind \
            carbon truly provide dizzy crush flush \
            breeze blouse charge solid fish spread
            """
            state.wordsCount = 24
            state.isValidNumberOfWords = true
            state.isValidMnemonic = true
        }
    }
    
    func testInvalidBirthdayHeight_lessThanDefault() throws {
        let testEnvironment = ImportWalletEnvironment(
            mnemonic: .mock,
            walletStorage: .throwing,
            zcashSDKEnvironment: .testnet
        )

        let store = TestStore(
            initialState: .placeholder,
            reducer: ImportWalletReducer.default,
            environment: testEnvironment
        )
        
        store.send(.binding(.set(\.$birthdayHeight, "1600000"))) { state in
            state.birthdayHeight = "1600000"
        }
    }

    func testInvalidBirthdayHeight_invalidInput() throws {
        let testEnvironment = ImportWalletEnvironment(
            mnemonic: .mock,
            walletStorage: .throwing,
            zcashSDKEnvironment: .testnet
        )

        let store = TestStore(
            initialState: .placeholder,
            reducer: ImportWalletReducer.default,
            environment: testEnvironment
        )
        
        store.send(.binding(.set(\.$birthdayHeight, "abc"))) { state in
            state.birthdayHeight = "abc"
        }
    }

    func testInvalidBirthdayHeight_validInput() throws {
        let testEnvironment = ImportWalletEnvironment(
            mnemonic: .mock,
            walletStorage: .throwing,
            zcashSDKEnvironment: .testnet
        )

        let store = TestStore(
            initialState: .placeholder,
            reducer: ImportWalletReducer.default,
            environment: testEnvironment
        )
        
        store.send(.binding(.set(\.$birthdayHeight, "1700000"))) { state in
            state.birthdayHeight = "1700000"
            state.birthdayHeightValue = 1_700_000
        }
    }
    
    func testDismissAlert() throws {
        let testEnvironment = ImportWalletEnvironment(
            mnemonic: .mock,
            walletStorage: .throwing,
            zcashSDKEnvironment: .testnet
        )

        let store = TestStore(
            initialState:
                ImportWalletState(
                    alert: AlertState(
                        title: TextState("Success"),
                        message: TextState("The wallet has been successfully recovered."),
                        dismissButton: .default(
                            TextState("Ok"),
                            action: .send(.successfullyRecovered)
                        )
                    )
                ),
            reducer: ImportWalletReducer.default,
            environment: testEnvironment
        )
        
        store.send(.dismissAlert) { state in
            state.alert = nil
        }
    }
    
    func testFormValidity_validBirthday_invalidMnemonic() throws {
        let testEnvironment = ImportWalletEnvironment(
            mnemonic: .live,
            walletStorage: .throwing,
            zcashSDKEnvironment: .testnet
        )

        let store = TestStore(
            initialState: ImportWalletState(maxWordsCount: 24),
            reducer: ImportWalletReducer.default,
            environment: testEnvironment
        )
        
        store.send(.binding(.set(\.$birthdayHeight, "1700000"))) { state in
            state.birthdayHeight = "1700000"
            state.birthdayHeightValue = 1_700_000
        }
        
        store.send(.binding(.set(\.$importedSeedPhrase, "a a a a a a a a a a a a a a a a a a a a a a a a"))) { state in
            state.importedSeedPhrase = "a a a a a a a a a a a a a a a a a a a a a a a a"
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
        let testEnvironment = ImportWalletEnvironment(
            mnemonic: .live,
            walletStorage: .throwing,
            zcashSDKEnvironment: .testnet
        )

        let store = TestStore(
            initialState: ImportWalletState(maxWordsCount: 24),
            reducer: ImportWalletReducer.default,
            environment: testEnvironment
        )
        
        store.send(.binding(.set(\.$birthdayHeight, "1600000"))) { state in
            state.birthdayHeight = "1600000"
        }
        
        store.send(.binding(.set(\.$importedSeedPhrase, "a a a a a a a a a a a a a a a a a a a a a a a a"))) { state in
            state.importedSeedPhrase = "a a a a a a a a a a a a a a a a a a a a a a a a"
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
        let testEnvironment = ImportWalletEnvironment(
            mnemonic: .live,
            walletStorage: .throwing,
            zcashSDKEnvironment: .testnet
        )

        let store = TestStore(
            initialState: ImportWalletState(maxWordsCount: 24),
            reducer: ImportWalletReducer.default,
            environment: testEnvironment
        )
        
        store.send(.binding(.set(\.$birthdayHeight, "1600000"))) { state in
            state.birthdayHeight = "1600000"
        }
        
        store.send(
            .binding(
                .set(
                    \.$importedSeedPhrase,
            """
            still champion voice habit trend flight \
            survey between bitter process artefact blind \
            carbon truly provide dizzy crush flush \
            breeze blouse charge solid fish spread
            """
                )
            )
        ) { state in
            state.importedSeedPhrase = """
            still champion voice habit trend flight \
            survey between bitter process artefact blind \
            carbon truly provide dizzy crush flush \
            breeze blouse charge solid fish spread
            """
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
        let testEnvironment = ImportWalletEnvironment(
            mnemonic: .live,
            walletStorage: .throwing,
            zcashSDKEnvironment: .testnet
        )

        let store = TestStore(
            initialState: ImportWalletState(maxWordsCount: 24),
            reducer: ImportWalletReducer.default,
            environment: testEnvironment
        )
        
        store.send(.binding(.set(\.$birthdayHeight, "1700000"))) { state in
            state.birthdayHeight = "1700000"
            state.birthdayHeightValue = 1_700_000
        }
        
        store.send(
            .binding(
                .set(
                    \.$importedSeedPhrase,
            """
            still champion voice habit trend flight \
            survey between bitter process artefact blind \
            carbon truly provide dizzy crush flush \
            breeze blouse charge solid fish spread
            """
                )
            )
        ) { state in
            state.importedSeedPhrase = """
            still champion voice habit trend flight \
            survey between bitter process artefact blind \
            carbon truly provide dizzy crush flush \
            breeze blouse charge solid fish spread
            """
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
        let testEnvironment = ImportWalletEnvironment(
            mnemonic: .live,
            walletStorage: .throwing,
            zcashSDKEnvironment: .testnet
        )

        let store = TestStore(
            initialState: ImportWalletState(maxWordsCount: 24),
            reducer: ImportWalletReducer.default,
            environment: testEnvironment
        )
        
        store.send(
            .binding(
                .set(
                    \.$importedSeedPhrase,
            """
            still champion voice habit trend flight \
            survey between bitter process artefact blind \
            carbon truly provide dizzy crush flush \
            breeze blouse charge solid fish spread
            """
                )
            )
        ) { state in
            state.importedSeedPhrase = """
            still champion voice habit trend flight \
            survey between bitter process artefact blind \
            carbon truly provide dizzy crush flush \
            breeze blouse charge solid fish spread
            """
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
        var storage = WalletStorage(secItem: .live)
        storage.zcashStoredWalletPrefix = "test_importWallet_"
        storage.deleteData(forKey: WalletStorage.Constants.zcashStoredWallet)

        let testEnvironment = ImportWalletEnvironment(
            mnemonic: .live,
            walletStorage: .live(walletStorage: storage),
            zcashSDKEnvironment: .testnet
        )

        let store = TestStore(
            initialState: ImportWalletState(
                alert: nil,
                importedSeedPhrase: """
            still champion voice habit trend flight \
            survey between bitter process artefact blind \
            carbon truly provide dizzy crush flush \
            breeze blouse charge solid fish spread
            """,
                birthdayHeight: "1700000",
                wordsCount: 24,
                maxWordsCount: 24,
                isValidMnemonic: true,
                isValidNumberOfWords: true,
                birthdayHeightValue: 1_700_000
            ),
            reducer: ImportWalletReducer.default,
            environment: testEnvironment
        )
        
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
