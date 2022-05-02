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
        
        let testEnvironment = SendEnvironment(
            mnemonicSeedPhraseProvider: .mock,
            scheduler: testScheduler.eraseToAnyScheduler(),
            walletStorage: .live(walletStorage: storage),
            wrappedDerivationTool: .live(),
            wrappedSDKSynchronizer: MockWrappedSDKSynchronizer()
        )

        let store = TestStore(
            initialState: .placeholder,
            reducer: SendReducer.default,
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
        
        let testEnvironment = SendEnvironment(
            mnemonicSeedPhraseProvider: .mock,
            scheduler: testScheduler.eraseToAnyScheduler(),
            walletStorage: .live(walletStorage: storage),
            wrappedDerivationTool: .live(),
            wrappedSDKSynchronizer: TestWrappedSDKSynchronizer()
        )

        let store = TestStore(
            initialState: .placeholder,
            reducer: SendReducer.default,
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
}
