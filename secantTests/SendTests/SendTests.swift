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

// swiftlint:disable type_body_length
class SendTests: XCTestCase {
    var storage = WalletStorage(secItem: .live)
    let usNumberFormatter = NumberFormatter()
    
    override func setUp() {
        super.setUp()
        storage.zcashStoredWalletPrefix = "test_send_"
        storage.deleteData(forKey: WalletStorage.Constants.zcashStoredWallet)
        
        usNumberFormatter.maximumFractionDigits = 8
        usNumberFormatter.maximumIntegerDigits = 8
        usNumberFormatter.numberStyle = .decimal
        usNumberFormatter.usesGroupingSeparator = true
        usNumberFormatter.locale = Locale(identifier: "en_US")
    }

    @MainActor func testSendSucceeded() async throws {
        // the test needs to pass the exportWallet() so we simulate some in the keychain
        try storage.importWallet(bip39: "one two three", birthday: nil)

        // setup the store and environment to be fully mocked
        let testScheduler = DispatchQueue.test

        var initialState = SendFlowReducer.State.placeholder
        initialState.transactionAddressInputState = TransactionAddressTextFieldReducer.State(
            textFieldState:
                TCATextFieldReducer.State(
                    validationType: nil,
                    text: "ztestsapling1psqa06alcfj9t6s246hht3n7kcw5h900r6z40qnuu7l58qs55kzeqa98879z9hzy596dca4hmsr"
                )
        )

        let store = TestStore(
            initialState: initialState,
            reducer: SendFlowReducer()
        ) { dependencies in
            dependencies.derivationTool = .liveValue
            dependencies.mainQueue = testScheduler.eraseToAnyScheduler()
            dependencies.mnemonic = .liveValue
            dependencies.sdkSynchronizer = SDKSynchronizerDependency.mock
            dependencies.walletStorage = .noOp
        }

        // simulate the sending confirmation button to be pressed
        _ = await store.send(.sendConfirmationPressed) { state in
            // once sending is confirmed, the attempts to try to send again by pressing the button
            // needs to be eliminated, indicated by the flag `isSendingTransaction`, need to be true
            state.isSendingTransaction = true
        }

        await testScheduler.advance(by: 0.01)

        let transactionState = TransactionState(
            expirationHeight: 40,
            memo: try? Memo(string: "test"),
            minedHeight: 50,
            shielded: true,
            zAddress: "tteafadlamnelkqe",
            fee: Zatoshi(10),
            id: "id",
            status: .paid(success: true),
            timestamp: 1234567,
            zecAmount: Zatoshi(10)
        )

        // first it's expected that progress screen is showed
        await store.receive(.updateDestination(.inProgress)) { state in
            state.destination = .inProgress
        }

        // check the success transaction to be received back
        await store.receive(.sendTransactionResult(Result.success(transactionState))) { state in
            // from this moment on the sending next transaction is allowed again
            // the 'isSendingTransaction' needs to be false again
            state.isSendingTransaction = false
        }
        
        // all went well, the success screen is triggered
        await store.receive(.updateDestination(.success)) { state in
            state.destination = .success
        }
    }

    @MainActor func testSendSucceededWithoutMemo() async throws {
        // the test needs to pass the exportWallet() so we simulate some in the keychain
        try storage.importWallet(bip39: "one two three", birthday: nil)

        // setup the store and environment to be fully mocked
        let testScheduler = DispatchQueue.test

        var state = SendFlowReducer.State.placeholder
        state.addMemoState = false
        state.transactionAddressInputState = TransactionAddressTextFieldReducer.State(
            textFieldState:
                TCATextFieldReducer.State(
                    validationType: nil,
                    text: "ztestsapling1psqa06alcfj9t6s246hht3n7kcw5h900r6z40qnuu7l58qs55kzeqa98879z9hzy596dca4hmsr"
                )
        )

        let store = TestStore(
            initialState: state,
            reducer: SendFlowReducer()
        ) { dependencies in
            dependencies.derivationTool = .liveValue
            dependencies.mainQueue = testScheduler.eraseToAnyScheduler()
            dependencies.mnemonic = .liveValue
            dependencies.sdkSynchronizer = SDKSynchronizerDependency.mock
            dependencies.walletStorage = .noOp
        }

        // simulate the sending confirmation button to be pressed
        _ = await store.send(.sendConfirmationPressed) { state in
            // once sending is confirmed, the attempts to try to send again by pressing the button
            // needs to be eliminated, indicated by the flag `isSendingTransaction`, need to be true
            state.isSendingTransaction = true
        }

        await testScheduler.advance(by: 0.01)

        let transactionState = TransactionState(
            expirationHeight: 40,
            memo: nil,
            minedHeight: 50,
            shielded: true,
            zAddress: "tteafadlamnelkqe",
            fee: Zatoshi(10),
            id: "id",
            status: .paid(success: true),
            timestamp: 1234567,
            zecAmount: Zatoshi(10)
        )

        // first it's expected that progress screen is showed
        await store.receive(.updateDestination(.inProgress)) { state in
            state.destination = .inProgress
        }

        // check the success transaction to be received back
        await store.receive(.sendTransactionResult(Result.success(transactionState))) { state in
            // from this moment on the sending next transaction is allowed again
            // the 'isSendingTransaction' needs to be false again
            state.isSendingTransaction = false
        }

        // all went well, the success screen is triggered
        await store.receive(.updateDestination(.success)) { state in
            state.destination = .success
        }
    }
    
    @MainActor func testSendFailed() async throws {
        // the test needs to pass the exportWallet() so we simulate some in the keychain
        try storage.importWallet(bip39: "one two three", birthday: nil)
        
        // setup the store and environment to be fully mocked
        let testScheduler = DispatchQueue.test

        var initialState = SendFlowReducer.State.placeholder
        initialState.transactionAddressInputState = TransactionAddressTextFieldReducer.State(
            textFieldState:
                TCATextFieldReducer.State(
                    validationType: nil,
                    text: "ztestsapling1psqa06alcfj9t6s246hht3n7kcw5h900r6z40qnuu7l58qs55kzeqa98879z9hzy596dca4hmsr"
                )
        )

        let store = TestStore(
            initialState: initialState,
            reducer: SendFlowReducer()
        ) { dependencies in
            dependencies.derivationTool = .liveValue
            dependencies.mainQueue = testScheduler.eraseToAnyScheduler()
            dependencies.mnemonic = .liveValue
            dependencies.walletStorage = .noOp
        }

        // simulate the sending confirmation button to be pressed
        _ = await store.send(.sendConfirmationPressed) { state in
            // once sending is confirmed, the attempts to try to send again by pressing the button
            // needs to be eliminated, indicated by the flag `isSendingTransaction`, need to be true
            state.isSendingTransaction = true
        }

        await testScheduler.advance(by: 0.01)

        // first it's expected that progress screen is showed
        await store.receive(.updateDestination(.inProgress)) { state in
            state.destination = .inProgress
        }

        // check the failure transaction to be received back
        await store.receive(.sendTransactionResult(Result.failure(SynchronizerError.criticalError as NSError))) { state in
            // from this moment on the sending next transaction is allowed again
            // the 'isSendingTransaction' needs to be false again
            state.isSendingTransaction = false
        }
        
        // the failure screen is triggered as expected
        await store.receive(.updateDestination(.failure)) { state in
            state.destination = .failure
        }
    }
    
    func testAddressValidation_Invalid() throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: SendFlowReducer()
        ) { dependencies in
            dependencies.derivationTool = .noOp
            dependencies.derivationTool.isValidZcashAddress = { _ in false }
        }

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
    }
    
    func testAddressValidation_Valid() throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: SendFlowReducer()
        ) { dependencies in
            dependencies.derivationTool = .noOp
            dependencies.derivationTool.isValidZcashAddress = { _ in true }
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
        let store = TestStore(
            initialState: .placeholder,
            reducer: SendFlowReducer()
        ) {
            $0.numberFormatter = .noOp
        }

        // Checks the computed property `isInvalidAmountFormat` which controls the error message to be shown on the screen
        // With empty input it must be false
        store.send(.transactionAmountInput(.textField(.set(""))))
        
        store.receive(.transactionAmountInput(.updateAmount))
    }
    
    func testInvalidAddressFormatEmptyInput() throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: SendFlowReducer()
        ) {
            $0.derivationTool = .noOp
        }

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
    
    func testFundsSufficiency_SufficientAmount() throws {
        let sendState = SendFlowReducer.State(
            addMemoState: true,
            memoState: .placeholder,
            scanState: .placeholder,
            transactionAddressInputState: .placeholder,
            transactionAmountInputState:
                TransactionAmountTextFieldReducer.State(
                    currencySelectionState: CurrencySelectionReducer.State(),
                    maxValue: 501_300,
                    textFieldState:
                        TCATextFieldReducer.State(
                            validationType: .customFloatingPoint(usNumberFormatter),
                            text: ""
                        )
                )
        )

        let store = TestStore(
            initialState: sendState,
            reducer: SendFlowReducer()
        ) { dependencies in
            dependencies.numberFormatter = .noOp
            dependencies.numberFormatter.number = { _ in NSNumber(0.00501299) }
        }

        store.send(.transactionAmountInput(.textField(.set("0.00501299")))) { state in
            state.transactionAmountInputState.textFieldState.text = "0.00501299"
            state.transactionAmountInputState.textFieldState.valid = true
            XCTAssertFalse(
                state.isInsufficientFunds,
                "Send Tests: `testFundsSufficiency` is expected to be false but it's \(state.isInsufficientFunds)"
            )
        }
        
        store.receive(.transactionAmountInput(.updateAmount)) { state in
            state.transactionAmountInputState.amount = 501_299
        }
    }
    
    func testFundsSufficiency_InsufficientAmount() throws {
        let sendState = SendFlowReducer.State(
            addMemoState: true,
            memoState: .placeholder,
            scanState: .placeholder,
            transactionAddressInputState: .placeholder,
            transactionAmountInputState:
                TransactionAmountTextFieldReducer.State(
                    currencySelectionState: CurrencySelectionReducer.State(),
                    maxValue: 501_300,
                    textFieldState:
                        TCATextFieldReducer.State(
                            validationType: .customFloatingPoint(usNumberFormatter),
                            text: ""
                        )
                )
        )

        let store = TestStore(
            initialState: sendState,
            reducer: SendFlowReducer()
        ) { dependencies in
            dependencies.numberFormatter = .noOp
            dependencies.numberFormatter.number = { _ in NSNumber(0.00501301) }
        }

        store.send(.transactionAmountInput(.textField(.set("0.00501301")))) { state in
            state.transactionAmountInputState.textFieldState.text = "0.00501301"
            state.transactionAmountInputState.textFieldState.valid = true
            XCTAssertFalse(
                state.isInsufficientFunds,
                "Send Tests: `testFundsSufficiency` is expected to be false but it's \(state.isInsufficientFunds)"
            )
        }
        
        store.receive(.transactionAmountInput(.updateAmount)) { state in
            state.transactionAmountInputState.amount = 501_301
            XCTAssertTrue(
                state.isInsufficientFunds,
                "Send Tests: `testFundsSufficiency` is expected to be true but it's \(state.isInsufficientFunds)"
            )
        }
    }
    
    func testDifferentNumberFormats_LiveNumberFormatter() throws {
        try numberFormatTest("1.234", NSNumber(1.234))
        try numberFormatTest("1,234", NSNumber(1_234))
        try numberFormatTest("1 234", NSNumber(1_234))
        try numberFormatTest("1,234.567", NSNumber(1_234.567))
        try numberFormatTest("1.", NSNumber(1))
        try numberFormatTest("1..", nil)
        try numberFormatTest("1,.", nil)
        try numberFormatTest("1.,", nil)
        try numberFormatTest("1,,", nil)
        try numberFormatTest("1,23", nil)
        try numberFormatTest("1 23", nil)
        try numberFormatTest("1.2.3", nil)
    }
    
    func testValidForm() throws {
        let sendState = SendFlowReducer.State(
            addMemoState: true,
            memoState: .placeholder,
            scanState: .placeholder,
            transactionAddressInputState: .placeholder,
            transactionAmountInputState:
                TransactionAmountTextFieldReducer.State(
                    amount: 501_301,
                    currencySelectionState: CurrencySelectionReducer.State(),
                    maxValue: 501_302,
                    textFieldState:
                        TCATextFieldReducer.State(
                            validationType: .customFloatingPoint(usNumberFormatter),
                            text: "0.00501301"
                        )
                )
        )
        
        let store = TestStore(
            initialState: sendState,
            reducer: SendFlowReducer()
        ) { dependencies in
            dependencies.derivationTool = .noOp
            dependencies.derivationTool.isValidZcashAddress = { _ in true }
        }

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
        let sendState = SendFlowReducer.State(
            addMemoState: true,
            memoState: .placeholder,
            scanState: .placeholder,
            transactionAddressInputState: .placeholder,
            transactionAmountInputState:
                TransactionAmountTextFieldReducer.State(
                    currencySelectionState: CurrencySelectionReducer.State(),
                    maxValue: 501_300,
                    textFieldState:
                        TCATextFieldReducer.State(
                            validationType: .floatingPoint,
                            text: "0.00501301"
                        )
                )
        )

        let store = TestStore(
            initialState: sendState,
            reducer: SendFlowReducer()
        ) { dependencies in
            dependencies.derivationTool = .noOp
            dependencies.derivationTool.isValidZcashAddress = { _ in true }
        }

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
        let sendState = SendFlowReducer.State(
            addMemoState: true,
            memoState: .placeholder,
            scanState: .placeholder,
            transactionAddressInputState: .placeholder,
            transactionAmountInputState:
                TransactionAmountTextFieldReducer.State(
                    currencySelectionState: CurrencySelectionReducer.State(),
                    maxValue: 501_302,
                    textFieldState:
                        TCATextFieldReducer.State(
                            validationType: .floatingPoint,
                            text: "0.00501301"
                        )
                )
        )
        
        let store = TestStore(
            initialState: sendState,
            reducer: SendFlowReducer()
        ) {
            $0.derivationTool = .noOp
        }

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
        let sendState = SendFlowReducer.State(
            addMemoState: true,
            memoState: .placeholder,
            scanState: .placeholder,
            transactionAddressInputState: .placeholder,
            transactionAmountInputState:
                TransactionAmountTextFieldReducer.State(
                    currencySelectionState: CurrencySelectionReducer.State(),
                    maxValue: 501_302,
                    textFieldState:
                        TCATextFieldReducer.State(
                            validationType: .floatingPoint,
                            text: "0.0.0501301"
                        )
                )
        )

        let store = TestStore(
            initialState: sendState,
            reducer: SendFlowReducer()
        ) { dependencies in
            dependencies.derivationTool = .noOp
            dependencies.derivationTool.isValidZcashAddress = { _ in true }
        }

        store.send(.transactionAddressInput(.textField(.set("tmGh6ttAnQRJra81moqYcedFadW9XtUT5Eq")))) { state in
            state.transactionAddressInputState.textFieldState.text = "tmGh6ttAnQRJra81moqYcedFadW9XtUT5Eq"
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
    
    func testInvalidForm_ExceededMemoCharLimit() throws {
        let sendState = SendFlowReducer.State(
            addMemoState: true,
            memoState: MultiLineTextFieldReducer.State(charLimit: 3),
            scanState: .placeholder,
            shieldedBalance: WalletBalance(verified: Zatoshi(1), total: Zatoshi(1)),
            transactionAddressInputState:
                TransactionAddressTextFieldReducer.State(
                    isValidAddress: true,
                    textFieldState:
                        TCATextFieldReducer.State(
                            validationType: .none,
                            text: "t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po"
                        )
                ),
            transactionAmountInputState:
                TransactionAmountTextFieldReducer.State(
                    amount: 100,
                    currencySelectionState: CurrencySelectionReducer.State(),
                    maxValue: 501_302,
                    textFieldState:
                        TCATextFieldReducer.State(
                            validationType: .floatingPoint,
                            text: "0.0.0501301"
                        )
                )
        )
        
        let store = TestStore(
            initialState: sendState,
            reducer: SendFlowReducer()
        )

        store.send(.memo(.binding(.set(\.$text, "test")))) { state in
            state.memoState.text = "test"
            XCTAssertFalse(
                state.isValidForm,
                "Send Tests: `testValidForm` is expected to be false but it's \(state.isValidForm)"
            )
        }
    }
    
    func testMemoCharLimitSet() throws {
        let sendState = SendFlowReducer.State(
            addMemoState: true,
            memoState: .placeholder,
            scanState: .placeholder,
            transactionAddressInputState: .placeholder,
            transactionAmountInputState:
                TransactionAmountTextFieldReducer.State(
                    currencySelectionState: CurrencySelectionReducer.State(),
                    maxValue: 501_302,
                    textFieldState:
                        TCATextFieldReducer.State(
                            validationType: .floatingPoint,
                            text: "0.0.0501301"
                        )
                )
        )

        let store = TestStore(
            initialState: sendState,
            reducer: SendFlowReducer()
        )

        store.send(.onAppear) { state in
            state.memoState.charLimit = 512
        }

        store.receive(.synchronizerStateChanged(.unknown))
        
        // .onAppear action starts long living cancelable action .synchronizerStateChanged
        // .onDisappear cancels it, must have for the test to pass
        store.send(.onDisappear)
    }
    
    func testScannedAddress() throws {
        let sendState = SendFlowReducer.State(
            addMemoState: true,
            memoState: .placeholder,
            scanState: .placeholder,
            transactionAddressInputState: .placeholder,
            transactionAmountInputState: .placeholder
        )

        let store = TestStore(
            initialState: sendState,
            reducer: SendFlowReducer()
        )

        store.dependencies.audioServices = AudioServicesClient(systemSoundVibrate: { })
        
        // We don't need to pass a valid address here, we just need to confirm some
        // found string is received and the `isValidAddress` flag is set to `true`
        store.send(.scan(.found("address"))) { state in
            state.transactionAddressInputState.textFieldState.text = "address"
            state.transactionAddressInputState.isValidAddress = true
        }
        
        store.receive(.updateDestination(nil))
    }
}

private extension SendTests {
    func numberFormatTest(
        _ amount: String,
        _ expectedResult: NSNumber?
    ) throws {
        if let number = NumberFormatterClient.liveValue.number(amount) {
            XCTAssertEqual(number, expectedResult)
            return
        } else {
            XCTAssertEqual(nil, expectedResult, "NumberFormatterClient.liveValue.number(\(amount)) unexpected result.")
        }
    }
}
