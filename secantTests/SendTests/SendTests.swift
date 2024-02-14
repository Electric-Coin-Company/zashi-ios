//
//  SendTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 02.05.2022.
//

import XCTest
import ComposableArchitecture
import ZcashLightClientKit
import AudioServices
import NumberFormatter
import Models
import WalletStorage
import SendFlow
import UIComponents
@testable import secant_testnet

// swiftlint:disable type_body_length
@MainActor
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

        var initialState = SendFlowReducer.State.initial
        initialState.transactionAddressInputState = TransactionAddressTextFieldReducer.State(
            textFieldState:
                TCATextFieldReducer.State(
                    validationType: nil,
                    text: "ztestsapling1psqa06alcfj9t6s246hht3n7kcw5h900r6z40qnuu7l58qs55kzeqa98879z9hzy596dca4hmsr".redacted
                )
        )

        let store = TestStore(
            initialState: initialState
        ) {
            SendFlowReducer()
        }
        
        store.dependencies.derivationTool = .liveValue
        store.dependencies.mainQueue = .immediate
        store.dependencies.mnemonic = .liveValue
        store.dependencies.sdkSynchronizer = .mocked()
        store.dependencies.walletStorage = .noOp
        
        // simulate the sending confirmation button to be pressed
        await store.send(.sendPressed) { state in
            // once sending is confirmed, the attempts to try to send again by pressing the button
            // needs to be eliminated, indicated by the flag `isSending`, need to be true
            state.isSending = true
        }
        
        let transaction = TransactionState(
            expiryHeight: 40,
            memos: [],
            minedHeight: 50,
            shielded: true,
            zAddress: "tteafadlamnelkqe",
            fee: Zatoshi(10),
            id: "id",
            status: .paid,
            timestamp: 1234567,
            zecAmount: Zatoshi(10)
        )
        
        await store.receive(.sendDone(transaction)) { state in
            state.isSending = false
            state.transactionAddressInputState.textFieldState.text = "".redacted
            state.transactionAmountInputState.textFieldState.text = "".redacted
        }

        await store.finish()
    }
    
    @MainActor func testSendFailed() async throws {
        // the test needs to pass the exportWallet() so we simulate some in the keychain
        try storage.importWallet(bip39: "one two three", birthday: nil)

        var initialState = SendFlowReducer.State.initial
        initialState.transactionAddressInputState = TransactionAddressTextFieldReducer.State(
            textFieldState:
                TCATextFieldReducer.State(
                    validationType: nil,
                    text: "ztestsapling1psqa06alcfj9t6s246hht3n7kcw5h900r6z40qnuu7l58qs55kzeqa98879z9hzy596dca4hmsr".redacted
                )
        )

        let store = TestStore(
            initialState: initialState
        ) {
            SendFlowReducer()
        }
        
        let error = "send failed".toZcashError()
        
        store.dependencies.derivationTool = .liveValue
        store.dependencies.mainQueue = .immediate
        store.dependencies.mnemonic = .liveValue
        store.dependencies.sdkSynchronizer = .mocked(sendTransaction: { _, _, _, _ in throw error })
        store.dependencies.walletStorage = .noOp
        
        // simulate the sending confirmation button to be pressed
        await store.send(.sendPressed) { state in
            // once sending is confirmed, the attempts to try to send again by pressing the button
            // needs to be eliminated, indicated by the flag `isSending`, need to be true
            state.isSending = true
        }
                
        await store.receive(.sendFailed(error)) { state in
            state.isSending = false
            state.alert = AlertState.sendFailure(error)
        }

        await store.finish()
    }
    
    @MainActor func testSendFailedBeforeHitSynchronizer() async throws {
        // the test needs to pass the exportWallet() so we simulate some in the keychain
        try storage.importWallet(bip39: "one two three", birthday: nil)

        var initialState = SendFlowReducer.State.initial
        initialState.transactionAddressInputState = TransactionAddressTextFieldReducer.State(
            textFieldState:
                TCATextFieldReducer.State(
                    validationType: nil,
                    text: "ztestsapling1psqa06alcfj9t6s246hht3n7kcw5h900r6z40qnuu7l58qs55kzeqa98879z9hzy596dca4hmsr".redacted
                )
        )

        let store = TestStore(
            initialState: initialState
        ) {
            SendFlowReducer()
        }
        
        store.dependencies.derivationTool = .liveValue
        store.dependencies.mainQueue = .immediate
        store.dependencies.mnemonic = .liveValue
        store.dependencies.sdkSynchronizer = .noOp
        store.dependencies.walletStorage = .noOp
        
        let walletStorageError: ZcashError = "export failed".toZcashError()
        store.dependencies.walletStorage.exportWallet = { throw walletStorageError }
        
        // simulate the sending confirmation button to be pressed
        await store.send(.sendPressed)
                
        await store.receive(.sendFailed(walletStorageError)) { state in
            state.isSending = false
            state.alert = AlertState.sendFailure(walletStorageError)
        }

        await store.finish()
    }

    func testAddressValidation_Invalid() async throws {
        let store = TestStore(
            initialState: .initial
        ) {
            SendFlowReducer()
        }

        store.dependencies.derivationTool = .noOp
        store.dependencies.derivationTool.isZcashAddress = { _, _ in false }

        let address = "3HRG769ii3HDSJV5vNknQPzXqtL2mTSGnr".redacted
        
        await store.send(.transactionAddressInput(.textField(.set(address)))) { state in
            state.transactionAddressInputState.textFieldState.text = address
            // true is expected here because textField doesn't have any `validationType: String.ValidationType?`
            // isValid function returns true, `guard let validationType else { return true }`
            state.transactionAddressInputState.textFieldState.valid = true
            state.transactionAddressInputState.isValidAddress = false
            XCTAssertTrue(
                state.isInvalidAddressFormat,
                "Send Tests: `testAddressValidation` is expected to be true but it's \(state.isInvalidAddressFormat)"
            )
        }
    }

    func testAddressValidation_Valid() async throws {
        let store = TestStore(
            initialState: .initial
        ) {
            SendFlowReducer()
        }

        store.dependencies.derivationTool = .noOp
        store.dependencies.derivationTool.isZcashAddress = { _, _ in true }

        let address = "t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po".redacted
        
        await store.send(.transactionAddressInput(.textField(.set(address)))) { state in
            state.transactionAddressInputState.textFieldState.text = address
            // true is expected here because textField doesn't have any `validationType: String.ValidationType?`
            // isValid function returns true, `guard let validationType else { return true }`
            state.transactionAddressInputState.textFieldState.valid = true
            state.transactionAddressInputState.isValidAddress = true
            XCTAssertFalse(
                state.isInvalidAddressFormat,
                "Send Tests: `testAddressValidation` is expected to be false but it's \(state.isInvalidAddressFormat)"
            )
        }
    }

    func testInvalidAmountFormatEmptyInput() async throws {
        var state = SendFlowReducer.State.initial
        state.transactionAmountInputState = .amount
        
        let store = TestStore(
            initialState: state
        ) {
            SendFlowReducer()
        }

        store.dependencies.numberFormatter = .noOp

        // Checks the computed property `isInvalidAmountFormat` which controls the error message to be shown on the screen
        // With empty input it must be false
        await store.send(.transactionAmountInput(.textField(.set("".redacted))))

        await store.receive(.transactionAmountInput(.updateAmount))
    }

    func testInvalidAddressFormatEmptyInput() async throws {
        let store = TestStore(
            initialState: .initial
        ) {
            SendFlowReducer()
        }

        store.dependencies.derivationTool = .noOp

        // Checks the computed property `isInvalidAddressFormat` which controls the error message to be shown on the screen
        // With empty input it must be false
        await store.send(.transactionAddressInput(.textField(.set("".redacted)))) { state in
            state.transactionAddressInputState.textFieldState.text = "".redacted
            // true is expected here because textField doesn't have any `validationType: String.ValidationType?`
            // isValid function returns true, `guard let validationType else { return true }`
            state.transactionAddressInputState.textFieldState.valid = true
            XCTAssertFalse(
                state.isInvalidAddressFormat,
                "Send Tests: `testInvalidAddressFormatEmptyInput` is expected to be false but it's \(state.isInvalidAddressFormat)"
            )
        }
    }

    func testFundsSufficiency_SufficientAmount() async throws {
        let sendState = SendFlowReducer.State(
            addMemoState: true,
            memoState: .initial,
            scanState: .initial,
            transactionAddressInputState: .initial,
            transactionAmountInputState:
                TransactionAmountTextFieldReducer.State(
                    currencySelectionState: CurrencySelectionReducer.State(),
                    maxValue: Int64(501_300).redacted,
                    textFieldState:
                        TCATextFieldReducer.State(
                            validationType: .customFloatingPoint(usNumberFormatter),
                            text: "".redacted
                        )
                )
        )

        let store = TestStore(
            initialState: sendState
        ) {
            SendFlowReducer()
        }

        store.dependencies.numberFormatter = .noOp
        store.dependencies.numberFormatter.number = { _ in NSNumber(0.00501299) }

        let address = "0.00501299".redacted
        
        await store.send(.transactionAmountInput(.textField(.set(address)))) { state in
            state.transactionAmountInputState.textFieldState.text = address
            state.transactionAmountInputState.textFieldState.valid = true
            XCTAssertFalse(
                state.isInsufficientFunds,
                "Send Tests: `testFundsSufficiency` is expected to be false but it's \(state.isInsufficientFunds)"
            )
        }

        await store.receive(.transactionAmountInput(.updateAmount)) { state in
            state.transactionAmountInputState.amount = Int64(501_299).redacted
        }
    }

    func testFundsSufficiency_InsufficientAmount() async throws {
        let sendState = SendFlowReducer.State(
            addMemoState: true,
            memoState: .initial,
            scanState: .initial,
            transactionAddressInputState: .initial,
            transactionAmountInputState:
                TransactionAmountTextFieldReducer.State(
                    currencySelectionState: CurrencySelectionReducer.State(),
                    maxValue: Int64(501_300).redacted,
                    textFieldState:
                        TCATextFieldReducer.State(
                            validationType: .customFloatingPoint(usNumberFormatter),
                            text: "".redacted
                        )
                )
        )

        let store = TestStore(
            initialState: sendState
        ) {
            SendFlowReducer()
        }

        store.dependencies.numberFormatter = .noOp
        store.dependencies.numberFormatter.number = { _ in NSNumber(0.00501301) }

        let value = "0.00501301".redacted
        
        await store.send(.transactionAmountInput(.textField(.set(value)))) { state in
            state.transactionAmountInputState.textFieldState.text = value
            state.transactionAmountInputState.textFieldState.valid = true
            XCTAssertFalse(
                state.isInsufficientFunds,
                "Send Tests: `testFundsSufficiency` is expected to be false but it's \(state.isInsufficientFunds)"
            )
        }

        await store.receive(.transactionAmountInput(.updateAmount)) { state in
            state.transactionAmountInputState.amount = Int64(501_301).redacted
            XCTAssertTrue(
                state.isInsufficientFunds,
                "Send Tests: `testFundsSufficiency` is expected to be true but it's \(state.isInsufficientFunds)"
            )
        }
    }

    func testDifferentNumberFormats_LiveNumberFormatter() throws {
        let zcashNumberFormatter = NumberFormatter.zcashNumberFormatter
        zcashNumberFormatter.locale = Locale(identifier: "en_US")
        
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

    func testValidForm() async throws {
        let sendState = SendFlowReducer.State(
            addMemoState: true,
            memoState: .initial,
            scanState: .initial,
            transactionAddressInputState: .initial,
            transactionAmountInputState:
                TransactionAmountTextFieldReducer.State(
                    amount: Int64(501_301).redacted,
                    currencySelectionState: CurrencySelectionReducer.State(),
                    maxValue: Int64(501_302).redacted,
                    textFieldState:
                        TCATextFieldReducer.State(
                            validationType: .customFloatingPoint(usNumberFormatter),
                            text: "0.00501301".redacted
                        )
                )
        )

        let store = TestStore(
            initialState: sendState
        ) {
            SendFlowReducer()
        }

        store.dependencies.derivationTool = .noOp
        store.dependencies.derivationTool.isZcashAddress = { _, _ in true }

        let address = "t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po".redacted
        
        await store.send(.transactionAddressInput(.textField(.set(address)))) { state in
            state.transactionAddressInputState.textFieldState.text = address
            // true is expected here because textField doesn't have any `validationType: String.ValidationType?`
            // isValid function returns true, `guard let validationType else { return true }`
            state.transactionAddressInputState.textFieldState.valid = true
            state.transactionAddressInputState.isValidAddress = true
            XCTAssertTrue(
                state.isValidForm,
                "Send Tests: `testValidForm` is expected to be true but it's \(state.isValidForm)"
            )
        }
    }

    func testValidForm_NoFees() async throws {
        let sendState = SendFlowReducer.State(
            addMemoState: true,
            memoState: .initial,
            scanState: .initial,
            transactionAddressInputState: .initial,
            transactionAmountInputState:
                TransactionAmountTextFieldReducer.State(
                    amount: Int64(9_000).redacted,
                    currencySelectionState: CurrencySelectionReducer.State(),
                    maxValue: Int64(501_302).redacted,
                    textFieldState:
                        TCATextFieldReducer.State(
                            validationType: .customFloatingPoint(usNumberFormatter),
                            text: "0.00501301".redacted
                        )
                )
        )
        
        let store = TestStore(
            initialState: sendState
        ) {
            SendFlowReducer()
        }
        
        store.dependencies.derivationTool = .noOp
        store.dependencies.derivationTool.isZcashAddress = { _, _ in true }
        
        let address = "t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po".redacted
        
        await store.send(.transactionAddressInput(.textField(.set(address)))) { state in
            state.transactionAddressInputState.textFieldState.text = address
            // true is expected here because textField doesn't have any `validationType: String.ValidationType?`
            // isValid function returns true, `guard let validationType else { return true }`
            state.transactionAddressInputState.textFieldState.valid = true
            state.transactionAddressInputState.isValidAddress = true
            XCTAssertFalse(
                state.isValidForm,
                "Send Tests: `testValidForm` is expected to be false but it's \(state.isValidForm)"
            )
        }
    }

    func testInvalidForm_InsufficientFunds() async throws {
        let sendState = SendFlowReducer.State(
            addMemoState: true,
            memoState: .initial,
            scanState: .initial,
            transactionAddressInputState: .initial,
            transactionAmountInputState:
                TransactionAmountTextFieldReducer.State(
                    currencySelectionState: CurrencySelectionReducer.State(),
                    maxValue: Int64(501_300).redacted,
                    textFieldState:
                        TCATextFieldReducer.State(
                            validationType: .floatingPoint,
                            text: "0.00501301".redacted
                        )
                )
        )

        let store = TestStore(
            initialState: sendState
        ) {
            SendFlowReducer()
        }

        store.dependencies.derivationTool = .noOp
        store.dependencies.derivationTool.isZcashAddress = { _, _ in true }

        let address = "t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po".redacted
        
        await store.send(.transactionAddressInput(.textField(.set(address)))) { state in
            state.transactionAddressInputState.textFieldState.text = address
            // true is expected here because textField doesn't have any `validationType: String.ValidationType?`
            // isValid function returns true, `guard let validationType else { return true }`
            state.transactionAddressInputState.textFieldState.valid = true
            state.transactionAddressInputState.isValidAddress = true
            XCTAssertFalse(
                state.isValidForm,
                "Send Tests: `testValidForm` is expected to be false but it's \(state.isValidForm)"
            )
        }
    }

    func testInvalidForm_AddressFormat() async throws {
        let sendState = SendFlowReducer.State(
            addMemoState: true,
            memoState: .initial,
            scanState: .initial,
            transactionAddressInputState: .initial,
            transactionAmountInputState:
                TransactionAmountTextFieldReducer.State(
                    currencySelectionState: CurrencySelectionReducer.State(),
                    maxValue: Int64(501_302).redacted,
                    textFieldState:
                        TCATextFieldReducer.State(
                            validationType: .floatingPoint,
                            text: "0.00501301".redacted
                        )
                )
        )

        let store = TestStore(
            initialState: sendState
        ) {
            SendFlowReducer()
        }

        store.dependencies.derivationTool = .noOp

        let address = "3HRG769ii3HDSJV5vNknQPzXqtL2mTSGnr".redacted
        
        await store.send(.transactionAddressInput(.textField(.set(address)))) { state in
            state.transactionAddressInputState.textFieldState.text = address
            // true is expected here because textField doesn't have any `validationType: String.ValidationType?`
            // isValid function returns true, `guard let validationType else { return true }`
            state.transactionAddressInputState.textFieldState.valid = true
            state.transactionAddressInputState.isValidAddress = false
            XCTAssertFalse(
                state.isValidForm,
                "Send Tests: `testValidForm` is expected to be false but it's \(state.isValidForm)"
            )
        }
    }

    func testInvalidForm_AmountFormat() async throws {
        let sendState = SendFlowReducer.State(
            addMemoState: true,
            memoState: .initial,
            scanState: .initial,
            transactionAddressInputState: .initial,
            transactionAmountInputState:
                TransactionAmountTextFieldReducer.State(
                    currencySelectionState: CurrencySelectionReducer.State(),
                    maxValue: Int64(501_302).redacted,
                    textFieldState:
                        TCATextFieldReducer.State(
                            validationType: .floatingPoint,
                            text: "0.0.0501301".redacted
                        )
                )
        )

        let store = TestStore(
            initialState: sendState
        ) {
            SendFlowReducer()
        }

        store.dependencies.derivationTool = .noOp
        store.dependencies.derivationTool.isZcashAddress = { _, _ in true }
        store.dependencies.derivationTool.isTransparentAddress = { _, _ in true }

        let address = "tmGh6ttAnQRJra81moqYcedFadW9XtUT5Eq".redacted
        
        await store.send(.transactionAddressInput(.textField(.set(address)))) { state in
            state.transactionAddressInputState.textFieldState.text = address
            // true is expected here because textField doesn't have any `validationType: String.ValidationType?`
            // isValid function returns true, `guard let validationType else { return true }`
            state.transactionAddressInputState.textFieldState.valid = true
            state.transactionAddressInputState.isValidAddress = true
            state.transactionAddressInputState.isValidTransparentAddress = true
            XCTAssertFalse(
                state.isValidForm,
                "Send Tests: `testValidForm` is expected to be false but it's \(state.isValidForm)"
            )
        }
    }

    func testInvalidForm_ExceededMemoCharLimit() async throws {
        let sendState = SendFlowReducer.State(
            addMemoState: true,
            memoState: MessageEditorReducer.State(charLimit: 3),
            scanState: .initial,
            shieldedBalance: Zatoshi(1),
            transactionAddressInputState:
                TransactionAddressTextFieldReducer.State(
                    isValidAddress: true,
                    textFieldState:
                        TCATextFieldReducer.State(
                            validationType: .none,
                            text: "t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po".redacted
                        )
                ),
            transactionAmountInputState:
                TransactionAmountTextFieldReducer.State(
                    amount: Int64(100).redacted,
                    currencySelectionState: CurrencySelectionReducer.State(),
                    maxValue: Int64(501_302).redacted,
                    textFieldState:
                        TCATextFieldReducer.State(
                            validationType: .floatingPoint,
                            text: "0.0.0501301".redacted
                        )
                )
        )

        let store = TestStore(
            initialState: sendState
        ) {
            SendFlowReducer()
        }

        let value = "test".redacted
        
        await store.send(.memo(.memoInputChanged(value))) { state in
            state.memoState.text = value
            XCTAssertFalse(
                state.isValidForm,
                "Send Tests: `testValidForm` is expected to be false but it's \(state.isValidForm)"
            )
        }
    }

    func testMemoCharLimitSet() async throws {
        let sendState = SendFlowReducer.State(
            addMemoState: true,
            memoState: .initial,
            scanState: .initial,
            transactionAddressInputState: .initial,
            transactionAmountInputState:
                TransactionAmountTextFieldReducer.State(
                    currencySelectionState: CurrencySelectionReducer.State(),
                    maxValue: Int64(501_302).redacted,
                    textFieldState:
                        TCATextFieldReducer.State(
                            validationType: .floatingPoint,
                            text: "0.0.0501301".redacted
                        )
                )
        )

        let store = TestStore(
            initialState: sendState
        ) {
            SendFlowReducer()
        }

        store.dependencies.mainQueue = .immediate
        store.dependencies.sdkSynchronizer = .noOp

        await store.send(.onAppear) { state in
            state.memoState.charLimit = 512
        }

        // .onAppear action starts long living cancelable action .synchronizerStateChanged
        // .onDisappear cancels it, must have for the test to pass
        await store.send(.onDisappear)
    }

    func testScannedAddress() async throws {
        let sendState = SendFlowReducer.State(
            addMemoState: true,
            memoState: .initial,
            scanState: .initial,
            transactionAddressInputState: .initial,
            transactionAmountInputState: .initial
        )

        let store = TestStore(
            initialState: sendState
        ) {
            SendFlowReducer()
        }

        store.dependencies.audioServices = AudioServicesClient(systemSoundVibrate: { })
        store.dependencies.derivationTool = .noOp

        // We don't need to pass a valid address here, we just need to confirm some
        // found string is received and the `isValidAddress` flag is set to `true`
        let address = "address".redacted
        
        await store.send(.scan(.found(address))) { state in
            state.transactionAddressInputState.textFieldState.text = address
            state.transactionAddressInputState.isValidAddress = true
        }

        await store.receive(.updateDestination(nil))
    }
    
    func testReviewPressed() async throws {
        let sendState = SendFlowReducer.State(
            addMemoState: true,
            memoState: .initial,
            scanState: .initial,
            transactionAddressInputState: .initial,
            transactionAmountInputState: .initial
        )

        let store = TestStore(
            initialState: sendState
        ) {
            SendFlowReducer()
        }

        await store.send(.reviewPressed) { state in
            state.destination = .sendConfirmation
        }
    }
    
    func testMemoToMessage() throws {
        let testMessage = "test message".redacted
        
        let sendState = SendFlowReducer.State(
            addMemoState: true,
            memoState: MessageEditorReducer.State(charLimit: 512, text: testMessage),
            scanState: .initial,
            transactionAddressInputState: .initial,
            transactionAmountInputState: .initial
        )

        let store = TestStore(
            initialState: sendState
        ) {
            SendFlowReducer()
        }
        
        XCTAssertEqual(store.state.message, testMessage.data)
    }
    
    func testFeeFormat() throws {
        let zashiBalanceFormatter = NumberFormatter.zashiBalanceFormatter
        zashiBalanceFormatter.locale = Locale(identifier: "en_US")

        let feeFormat = "(Fee < 0.001)"
        
        let sendState = SendFlowReducer.State(
            addMemoState: true,
            memoState: .initial,
            scanState: .initial,
            transactionAddressInputState: .initial,
            transactionAmountInputState: .initial
        )

        let store = TestStore(
            initialState: sendState
        ) {
            SendFlowReducer()
        }
        
        XCTAssertEqual(store.state.feeFormat, feeFormat)
    }
}

private extension SendTests {
    func numberFormatTest(
        _ amount: String,
        _ expectedResult: NSNumber?
    ) throws {
        if let number = NumberFormatter.zcashNumberFormatter.number(from: amount) {
            XCTAssertEqual(number, expectedResult)
            return
        } else {
            XCTAssertEqual(nil, expectedResult, "NumberFormatterClient.liveValue.number(\(amount)) unexpected result.")
        }
    }
}
