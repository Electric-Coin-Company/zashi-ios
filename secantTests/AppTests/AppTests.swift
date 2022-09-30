//
//  AppTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 12.04.2022.
//

import XCTest
@testable import secant_testnet
import ComposableArchitecture

class AppTests: XCTestCase {
    static let testScheduler = DispatchQueue.test

    let testEnvironment = AppEnvironment(
        audioServices: .silent,
        databaseFiles: .throwing,
        deeplinkHandler: .live,
        derivationTool: .live(),
        diskSpaceChecker: .mockEmptyDisk,
        feedbackGenerator: .silent,
        mnemonic: .mock,
        recoveryPhraseRandomizer: .live,
        scheduler: testScheduler.eraseToAnyScheduler(),
        SDKSynchronizer: TestWrappedSDKSynchronizer(),
        walletStorage: .throwing,
        zcashSDKEnvironment: .mainnet
    )

    func testWalletInitializationState_Uninitialized() throws {
        let uninitializedEnvironment = AppEnvironment(
            audioServices: .silent,
            databaseFiles: .throwing,
            deeplinkHandler: .live,
            derivationTool: .live(),
            diskSpaceChecker: .mockEmptyDisk,
            feedbackGenerator: .silent,
            mnemonic: .mock,
            recoveryPhraseRandomizer: .live,
            scheduler: DispatchQueue.test.eraseToAnyScheduler(),
            SDKSynchronizer: TestWrappedSDKSynchronizer(),
            walletStorage: .throwing,
            zcashSDKEnvironment: .mainnet
        )

        let walletState = AppReducer.walletInitializationState(uninitializedEnvironment)
        
        XCTAssertEqual(walletState, .uninitialized)
    }

    func testWalletInitializationState_FilesPresentKeysMissing() throws {
        let wfmMock = WrappedFileManager(
            url: { _, _, _, _ in URL(fileURLWithPath: "") },
            fileExists: { _ in return true },
            removeItem: { _ in }
        )

        let keysMissingEnvironment = AppEnvironment(
            audioServices: .silent,
            databaseFiles: .live(databaseFiles: DatabaseFiles(fileManager: wfmMock)),
            deeplinkHandler: .live,
            derivationTool: .live(),
            diskSpaceChecker: .mockEmptyDisk,
            feedbackGenerator: .silent,
            mnemonic: .mock,
            recoveryPhraseRandomizer: .live,
            scheduler: Self.testScheduler.eraseToAnyScheduler(),
            SDKSynchronizer: TestWrappedSDKSynchronizer(),
            walletStorage: .throwing,
            zcashSDKEnvironment: .mainnet
        )

        let walletState = AppReducer.walletInitializationState(keysMissingEnvironment)
        
        XCTAssertEqual(walletState, .keysMissing)
    }

    func testWalletInitializationState_FilesMissingKeysMissing() throws {
        let wfmMock = WrappedFileManager(
            url: { _, _, _, _ in URL(fileURLWithPath: "") },
            fileExists: { _ in return false },
            removeItem: { _ in }
        )

        let keysMissingEnvironment = AppEnvironment(
            audioServices: .silent,
            databaseFiles: .live(databaseFiles: DatabaseFiles(fileManager: wfmMock)),
            deeplinkHandler: .live,
            derivationTool: .live(),
            diskSpaceChecker: .mockEmptyDisk,
            feedbackGenerator: .silent,
            mnemonic: .mock,
            recoveryPhraseRandomizer: .live,
            scheduler: Self.testScheduler.eraseToAnyScheduler(),
            SDKSynchronizer: TestWrappedSDKSynchronizer(),
            walletStorage: .throwing,
            zcashSDKEnvironment: .testnet
        )

        let walletState = AppReducer.walletInitializationState(keysMissingEnvironment)
        
        XCTAssertEqual(walletState, .uninitialized)
    }

    // TODO [#231]: - Implement testWalletInitializationState_FilesMissing when WalletStorage mock is available (https://github.com/zcash/secant-ios-wallet/issues/231)

    // TODO [#231]: - Implement testWalletInitializationState_Initialized when WalletStorage mock is available (https://github.com/zcash/secant-ios-wallet/issues/231)

    func testRespondToWalletInitializationState_Uninitialized() throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: AppReducer.default,
            environment: testEnvironment
        )
        
        store.send(.respondToWalletInitializationState(.uninitialized))
        
        Self.testScheduler.advance(by: 3)

        store.receive(.updateRoute(.onboarding)) {
            $0.route = .onboarding
            $0.appInitializationState = .uninitialized
        }
    }

    func testRespondToWalletInitializationState_KeysMissing() throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: AppReducer.default,
            environment: testEnvironment
        )
        
        store.send(.respondToWalletInitializationState(.keysMissing)) { state in
            state.appInitializationState = .keysMissing
        }
    }

    func testRespondToWalletInitializationState_FilesMissing() throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: AppReducer.default,
            environment: testEnvironment
        )
        
        store.send(.respondToWalletInitializationState(.filesMissing)) { state in
            state.appInitializationState = .filesMissing
        }
        
        store.receive(.initializeSDK) { state in
            // failed is expected because environment is throwing errors
            state.appInitializationState = .failed
        }

        store.receive(.checkBackupPhraseValidation)
    }
    
    func testRespondToWalletInitializationState_Initialized() throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: AppReducer.default,
            environment: testEnvironment
        )
        
        store.send(.respondToWalletInitializationState(.initialized))
        
        store.receive(.initializeSDK) { state in
            // failed is expected because environment is throwing errors
            state.appInitializationState = .failed
        }

        store.receive(.checkBackupPhraseValidation)
    }
    
    func testWalletEventReplyTo_validAddress() throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: AppReducer.default,
            environment: testEnvironment
        )
        
        let address = "t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po"
        store.send(.home(.walletEvents(.replyTo(address))))
        
        if let url = URL(string: "zcash:\(address)") {
            store.receive(.deeplink(url))
        }
    }
}
