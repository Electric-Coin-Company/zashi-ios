//
//  SendTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 02.05.2022.
//

import XCTest
@testable import secant_testnet
import ComposableArchitecture
import ZcashLightClientKit

// TODO: these tests will be updated with the Zatoshi/Balance representative once done, issue #272 https://github.com/zcash/secant-ios-wallet/issues/272

// TODO: these test will be updated with the NumberFormater dependency to handle locale, issue #312 (https://github.com/zcash/secant-ios-wallet/issues/312)

// swiftlint:disable type_body_length
class SendTests: XCTestCase {
    var storage = WalletStorage(secItem: .live)
    
    override func setUp() {
        super.setUp()
        storage.zcashStoredWalletPrefix = "test_"
        storage.deleteData(forKey: WalletStorage.Constants.zcashStoredWallet)
    }

    func testSendSucceeded() throws {
        // the test needs to pass the exportWallet() so we simulate some in the keychain
        try storage.importWallet(bip39: "one two three", birthday: nil)
        
        // setup the store and environment to be fully mocked
        let testScheduler = DispatchQueue.test

        let testEnvironment = SendFlowEnvironment(
            mnemonicSeedPhraseProvider: .mock,
            scheduler: testScheduler.eraseToAnyScheduler(),
            walletStorage: .live(walletStorage: storage),
            derivationTool: .live(),
            SDKSynchronizer: MockWrappedSDKSynchronizer()
        )

        let store = TestStore(
            initialState: .placeholder,
            reducer: SendFlowReducer.default,
            environment: testEnvironment
        )

        // simulate the sending confirmation button to be pressed
        store.send(.sendConfirmationPressed) { state in
            // once sending is confirmed, the attemts to try to send again by pressing the button
            // needs to be eliminated, indicated by the flag `isSendingTransaction`, need to be true
            state.isSendingTransaction = true
        }

        testScheduler.advance(by: 0.01)

        let transactionState = TransactionState(
            expirationHeight: 40,
            memo: "test",
            minedHeight: 50,
            shielded: true,
            zAddress: "tteafadlamnelkqe",
            date: Date.init(timeIntervalSince1970: 1234567),
            id: "id",
            status: .paid(success: true),
            subtitle: "sub",
            zecAmount: 10
        )

        // check the success transaction to be received back
        store.receive(.sendTransactionResult(Result.success(transactionState))) { state in
            // from this moment on the sending next transaction is allowed again
            // the 'isSendingTransaction' needs to be false again
            state.isSendingTransaction = false
        }
        
        // all went well, the success screen is triggered
        store.receive(.updateRoute(.success)) { state in
            state.route = .success
        }
    }
    
    func testSendFailed() throws {
        // the test needs to pass the exportWallet() so we simulate some in the keychain
        try storage.importWallet(bip39: "one two three", birthday: nil)
        
        // setup the store and environment to be fully mocked
        let testScheduler = DispatchQueue.test

        let testEnvironment = SendFlowEnvironment(
            mnemonicSeedPhraseProvider: .mock,
            scheduler: testScheduler.eraseToAnyScheduler(),
            walletStorage: .live(walletStorage: storage),
            derivationTool: .live(),
            SDKSynchronizer: TestWrappedSDKSynchronizer()
        )

        let store = TestStore(
            initialState: .placeholder,
            reducer: SendFlowReducer.default,
            environment: testEnvironment
        )

        // simulate the sending confirmation button to be pressed
        store.send(.sendConfirmationPressed) { state in
            // once sending is confirmed, the attemts to try to send again by pressing the button
            // needs to be eliminated, indicated by the flag `isSendingTransaction`, need to be true
            state.isSendingTransaction = true
        }

        testScheduler.advance(by: 0.01)

        // check the failure transaction to be received back
        store.receive(.sendTransactionResult(Result.failure(SynchronizerError.criticalError as NSError))) { state in
            // from this moment on the sending next transaction is allowed again
            // the 'isSendingTransaction' needs to be false again
            state.isSendingTransaction = false
        }
        
        // the failure screen is triggered as expected
        store.receive(.updateRoute(.failure)) { state in
            state.route = .failure
        }
    }
    
    func testAddressValidation() throws {
        let testScheduler = DispatchQueue.test
        
        let testEnvironment = SendFlowEnvironment(
            mnemonicSeedPhraseProvider: .mock,
            scheduler: testScheduler.eraseToAnyScheduler(),
            walletStorage: .live(walletStorage: WalletStorage(secItem: .live)),
            derivationTool: .live(),
            SDKSynchronizer: TestWrappedSDKSynchronizer()
        )

        let store = TestStore(
            initialState: .placeholder,
            reducer: SendFlowReducer.default,
            environment: testEnvironment
        )
        
        store.send(.transactionAddressInput(.textField(.set("3HRG769ii3HDSJV5vNknQPzXqtL2mTSGnr")))) { state in
            state.transactionAddressInputState.textFieldState.text = "3HRG769ii3HDSJV5vNknQPzXqtL2mTSGnr"
            // true is expected here because textField doesn't have any `validationType: String.ValidationType?`
            // isValid function returns true, `guard let validationType = validationType else { return true }`
            state.transactionAddressInputState.textFieldState.valid = true
            state.transactionAddressInputState.isValidAddress = false
            XCTAssertTrue(
                state.isInvalidAddressFormat,
                "Send Tests: `testAddressValidation` is expected to be true but it's \(state.isInvalidAddressFormat)"
            )
        }
        
        store.send(.transactionAddressInput(.textField(.set("t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po")))) { state in
            state.transactionAddressInputState.textFieldState.text = "t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po"
            // true is expected here because textField doesn't have any `validationType: String.ValidationType?`
            // isValid function returns true, `guard let validationType = validationType else { return true }`
            state.transactionAddressInputState.textFieldState.valid = true
            state.transactionAddressInputState.isValidAddress = true
            XCTAssertFalse(
                state.isInvalidAddressFormat,
                "Send Tests: `testAddressValidation` is expected to be false but it's \(state.isInvalidAddressFormat)"
            )
        }
    }
    
    func testInvalidAmountFormatEmptyInput() throws {
        let testScheduler = DispatchQueue.test
        
        let testEnvironment = SendFlowEnvironment(
            mnemonicSeedPhraseProvider: .mock,
            scheduler: testScheduler.eraseToAnyScheduler(),
            walletStorage: .live(walletStorage: WalletStorage(secItem: .live)),
            derivationTool: .live(),
            SDKSynchronizer: TestWrappedSDKSynchronizer()
        )

        let store = TestStore(
            initialState: .placeholder,
            reducer: SendFlowReducer.default,
            environment: testEnvironment
        )

        // Checks the computed property `isInvalidAmountFormat` which controls the error message to be shown on the screen
        // With empty input it must be false
        store.send(.transactionAmountInput(.textField(.set(""))))
    }
    
    func testInvalidAddressFormatEmptyInput() throws {
        let testScheduler = DispatchQueue.test
        
        let testEnvironment = SendFlowEnvironment(
            mnemonicSeedPhraseProvider: .mock,
            scheduler: testScheduler.eraseToAnyScheduler(),
            walletStorage: .live(walletStorage: WalletStorage(secItem: .live)),
            derivationTool: .live(),
            SDKSynchronizer: TestWrappedSDKSynchronizer()
        )

        let store = TestStore(
            initialState: .placeholder,
            reducer: SendFlowReducer.default,
            environment: testEnvironment
        )
        
        // Checks the computed property `isInvalidAddressFormat` which controls the error message to be shown on the screen
        // With empty input it must be false
        store.send(.transactionAddressInput(.textField(.set("")))) { state in
            state.transactionAddressInputState.textFieldState.text = ""
            // true is expected here because textField doesn't have any `validationType: String.ValidationType?`
            // isValid function returns true, `guard let validationType = validationType else { return true }`
            state.transactionAddressInputState.textFieldState.valid = true
            XCTAssertFalse(
                state.isInvalidAddressFormat,
                "Send Tests: `testInvalidAddressFormatEmptyInput` is expected to be false but it's \(state.isInvalidAddressFormat)"
            )
        }
    }
    
    func testFundsSufficiency() throws {
        try XCTSkipUnless(Locale.current.regionCode == "US", "testFundsSufficiency is designed to test US locale only")

        let sendState = SendFlowState(
            transaction: .placeholder,
            transactionAddressInputState: .placeholder,
            transactionAmountInputState:
                TransactionAmountTextFieldState(
                    textFieldState: .amount,
                    currencySelectionState: CurrencySelectionState(),
                    maxValue: 501_300
                )
        )
        
        let testScheduler = DispatchQueue.test
        
        let testEnvironment = SendFlowEnvironment(
            mnemonicSeedPhraseProvider: .mock,
            scheduler: testScheduler.eraseToAnyScheduler(),
            walletStorage: .live(walletStorage: WalletStorage(secItem: .live)),
            derivationTool: .live(),
            SDKSynchronizer: TestWrappedSDKSynchronizer()
        )

        let store = TestStore(
            initialState: sendState,
            reducer: SendFlowReducer.default,
            environment: testEnvironment
        )
        
        store.send(.transactionAmountInput(.textField(.set("0.00501299")))) { state in
            state.transactionAmountInputState.textFieldState.text = "0.00501299"
            state.transactionAmountInputState.textFieldState.valid = true
            XCTAssertFalse(
                state.isInsufficientFunds,
                "Send Tests: `testFundsSufficiency` is expected to be false but it's \(state.isInsufficientFunds)"
            )
        }
        
        store.send(.transactionAmountInput(.textField(.set("0.00501301")))) { state in
            state.transactionAmountInputState.textFieldState.text = "0.00501301"
            state.transactionAmountInputState.textFieldState.valid = true
            XCTAssertTrue(
                state.isInsufficientFunds,
                "Send Tests: `testFundsSufficiency` is expected to be true but it's \(state.isInsufficientFunds)"
            )
        }
    }
    
    func testDifferentAmountFormats() throws {
        try XCTSkipUnless(Locale.current.regionCode == "US", "testDifferentAmountFormats is designed to test US locale only")

        let testScheduler = DispatchQueue.test
        
        let testEnvironment = SendFlowEnvironment(
            mnemonicSeedPhraseProvider: .mock,
            scheduler: testScheduler.eraseToAnyScheduler(),
            walletStorage: .live(walletStorage: WalletStorage(secItem: .live)),
            derivationTool: .live(),
            SDKSynchronizer: TestWrappedSDKSynchronizer()
        )

        let store = TestStore(
            initialState: .placeholder,
            reducer: SendFlowReducer.default,
            environment: testEnvironment
        )
                
        try amountFormatTest("1.234", true, 123_400_000, store)
        try amountFormatTest("1,234", true, 123_400_000_000, store)
        try amountFormatTest("1 234", true, 123_400_000_000, store)
        try amountFormatTest("1,234.567", true, 123_456_700_000, store)
        try amountFormatTest("1.", true, 100_000_000, store)
        try amountFormatTest("1..", false, 0, store)
        try amountFormatTest("1,.", false, 0, store)
        try amountFormatTest("1.,", false, 0, store)
        try amountFormatTest("1,,", false, 0, store)
        try amountFormatTest("1,23", false, 0, store)
        try amountFormatTest("1 23", false, 0, store)
        try amountFormatTest("1.2.3", false, 0, store)
    }
    
    func testValidForm() throws {
        try XCTSkipUnless(Locale.current.regionCode == "US", "testValidForm is designed to test US locale only")

        let sendState = SendFlowState(
            transaction: .placeholder,
            transactionAddressInputState: .placeholder,
            transactionAmountInputState:
                TransactionAmountTextFieldState(
                    textFieldState:
                        TCATextFieldState(
                            validationType: .floatingPoint,
                            text: "0.00501301"
                        ),
                    currencySelectionState: CurrencySelectionState(),
                    maxValue: 501_302
                )
        )

        let testScheduler = DispatchQueue.test
        
        let testEnvironment = SendFlowEnvironment(
            mnemonicSeedPhraseProvider: .mock,
            scheduler: testScheduler.eraseToAnyScheduler(),
            walletStorage: .live(walletStorage: WalletStorage(secItem: .live)),
            derivationTool: .live(),
            SDKSynchronizer: TestWrappedSDKSynchronizer()
        )

        let store = TestStore(
            initialState: sendState,
            reducer: SendFlowReducer.default,
            environment: testEnvironment
        )
        
        store.send(.transactionAddressInput(.textField(.set("t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po")))) { state in
            state.transactionAddressInputState.textFieldState.text = "t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po"
            // true is expected here because textField doesn't have any `validationType: String.ValidationType?`
            // isValid function returns true, `guard let validationType = validationType else { return true }`
            state.transactionAddressInputState.textFieldState.valid = true
            state.transactionAddressInputState.isValidAddress = true
            XCTAssertTrue(
                state.isValidForm,
                "Send Tests: `testValidForm` is expected to be true but it's \(state.isValidForm)"
            )
        }
    }
    
    func testInvalidForm_InsufficientFunds() throws {
        let sendState = SendFlowState(
            transaction: .placeholder,
            transactionAddressInputState: .placeholder,
            transactionAmountInputState:
                TransactionAmountTextFieldState(
                    textFieldState:
                        TCATextFieldState(
                            validationType: .floatingPoint,
                            text: "0.00501301"
                        ),
                    currencySelectionState: CurrencySelectionState(),
                    maxValue: 501_300
                )
        )

        let testScheduler = DispatchQueue.test
        
        let testEnvironment = SendFlowEnvironment(
            mnemonicSeedPhraseProvider: .mock,
            scheduler: testScheduler.eraseToAnyScheduler(),
            walletStorage: .live(walletStorage: WalletStorage(secItem: .live)),
            derivationTool: .live(),
            SDKSynchronizer: TestWrappedSDKSynchronizer()
        )

        let store = TestStore(
            initialState: sendState,
            reducer: SendFlowReducer.default,
            environment: testEnvironment
        )
        
        store.send(.transactionAddressInput(.textField(.set("t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po")))) { state in
            state.transactionAddressInputState.textFieldState.text = "t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po"
            // true is expected here because textField doesn't have any `validationType: String.ValidationType?`
            // isValid function returns true, `guard let validationType = validationType else { return true }`
            state.transactionAddressInputState.textFieldState.valid = true
            state.transactionAddressInputState.isValidAddress = true
            XCTAssertFalse(
                state.isValidForm,
                "Send Tests: `testValidForm` is expected to be false but it's \(state.isValidForm)"
            )
        }
    }
    
    func testInvalidForm_AddressFormat() throws {
        let sendState = SendFlowState(
            transaction: .placeholder,
            transactionAddressInputState: .placeholder,
            transactionAmountInputState:
                TransactionAmountTextFieldState(
                    textFieldState:
                        TCATextFieldState(
                            validationType: .floatingPoint,
                            text: "0.00501301"
                        ),
                    currencySelectionState: CurrencySelectionState(),
                    maxValue: 501_302
                )
        )

        let testScheduler = DispatchQueue.test
        
        let testEnvironment = SendFlowEnvironment(
            mnemonicSeedPhraseProvider: .mock,
            scheduler: testScheduler.eraseToAnyScheduler(),
            walletStorage: .live(walletStorage: WalletStorage(secItem: .live)),
            derivationTool: .live(),
            SDKSynchronizer: TestWrappedSDKSynchronizer()
        )

        let store = TestStore(
            initialState: sendState,
            reducer: SendFlowReducer.default,
            environment: testEnvironment
        )
        
        store.send(.transactionAddressInput(.textField(.set("3HRG769ii3HDSJV5vNknQPzXqtL2mTSGnr")))) { state in
            state.transactionAddressInputState.textFieldState.text = "3HRG769ii3HDSJV5vNknQPzXqtL2mTSGnr"
            // true is expected here because textField doesn't have any `validationType: String.ValidationType?`
            // isValid function returns true, `guard let validationType = validationType else { return true }`
            state.transactionAddressInputState.textFieldState.valid = true
            state.transactionAddressInputState.isValidAddress = false
            XCTAssertFalse(
                state.isValidForm,
                "Send Tests: `testValidForm` is expected to be false but it's \(state.isValidForm)"
            )
        }
    }
    
    func testInvalidForm_AmountFormat() throws {
        let sendState = SendFlowState(
            transaction: .placeholder,
            transactionAddressInputState: .placeholder,
            transactionAmountInputState:
                TransactionAmountTextFieldState(
                    textFieldState:
                        TCATextFieldState(
                            validationType: .floatingPoint,
                            text: "0.0.0501301"
                        ),
                    currencySelectionState: CurrencySelectionState(),
                    maxValue: 501_302
                )
        )

        let testScheduler = DispatchQueue.test
        
        let testEnvironment = SendFlowEnvironment(
            mnemonicSeedPhraseProvider: .mock,
            scheduler: testScheduler.eraseToAnyScheduler(),
            walletStorage: .live(walletStorage: WalletStorage(secItem: .live)),
            derivationTool: .live(),
            SDKSynchronizer: TestWrappedSDKSynchronizer()
        )

        let store = TestStore(
            initialState: sendState,
            reducer: SendFlowReducer.default,
            environment: testEnvironment
        )
        
        store.send(.transactionAddressInput(.textField(.set("t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po")))) { state in
            state.transactionAddressInputState.textFieldState.text = "t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po"
            // true is expected here because textField doesn't have any `validationType: String.ValidationType?`
            // isValid function returns true, `guard let validationType = validationType else { return true }`
            state.transactionAddressInputState.textFieldState.valid = true
            state.transactionAddressInputState.isValidAddress = true
            XCTAssertFalse(
                state.isValidForm,
                "Send Tests: `testValidForm` is expected to be false but it's \(state.isValidForm)"
            )
        }
    }
}

private extension SendTests {
    func amountFormatTest(
        _ amount: String,
        _ expectedValidationResult: Bool,
        _ expectedAmount: Int64,
        _ store: TestStore<SendFlowState, SendFlowState, SendFlowAction, SendFlowAction, SendFlowEnvironment>
    ) throws {
        store.send(.transactionAmountInput(.textField(.set(amount)))) { state in
            state.transactionAmountInputState.textFieldState.text = amount
            state.transactionAmountInputState.textFieldState.valid = expectedValidationResult
            XCTAssertEqual(
                expectedAmount,
                state.transactionAmountInputState.amount,
                "Send Tests: `amountFormatTest` expected amount is \(expectedAmount) but result is \(state.isInvalidAddressFormat)"
            )
        }
    }
}
