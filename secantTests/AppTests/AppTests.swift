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

    func testWalletInitializationState_Uninitialized() throws {
        let walletState = AppReducer.walletInitializationState(
            databaseFiles: .noOp,
            walletStorage: .noOp,
            zcashSDKEnvironment: .testnet
        )

        XCTAssertEqual(walletState, .uninitialized)
    }

    func testWalletInitializationState_FilesPresentKeysMissing() throws {
        let wfmMock = FileManagerClient(
            url: { _, _, _, _ in .emptyURL },
            fileExists: { _ in return true },
            removeItem: { _ in }
        )

        let walletState = AppReducer.walletInitializationState(
            databaseFiles: .live(databaseFiles: DatabaseFiles(fileManager: wfmMock)),
            walletStorage: .noOp,
            zcashSDKEnvironment: .testnet
        )

        XCTAssertEqual(walletState, .keysMissing)
    }

    func testWalletInitializationState_FilesMissingKeysMissing() throws {
        let wfmMock = FileManagerClient(
            url: { _, _, _, _ in .emptyURL },
            fileExists: { _ in return false },
            removeItem: { _ in }
        )

        let walletState = AppReducer.walletInitializationState(
            databaseFiles: .live(databaseFiles: DatabaseFiles(fileManager: wfmMock)),
            walletStorage: .noOp,
            zcashSDKEnvironment: .testnet
        )

        XCTAssertEqual(walletState, .uninitialized)
    }

    // TODO [#231]: - Implement testWalletInitializationState_FilesMissing when WalletStorage mock is available (https://github.com/zcash/secant-ios-wallet/issues/231)

    // TODO [#231]: - Implement testWalletInitializationState_Initialized when WalletStorage mock is available (https://github.com/zcash/secant-ios-wallet/issues/231)

    func testRespondToWalletInitializationState_Uninitialized() throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: AppReducer()
        )
        
        store.dependencies.mainQueue = Self.testScheduler.eraseToAnyScheduler()

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
            reducer: AppReducer()
        )
        
        store.send(.respondToWalletInitializationState(.keysMissing)) { state in
            state.appInitializationState = .keysMissing
        }
    }

    func testRespondToWalletInitializationState_FilesMissing() throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: AppReducer()
        )
        
        store.dependencies.walletStorage = .noOp
        store.dependencies.walletStorage.exportWallet = { throw "export failed" }

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
            reducer: AppReducer()
        )
        
        store.dependencies.walletStorage = .noOp
        store.dependencies.walletStorage.exportWallet = { throw "export failed" }
        
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
            reducer: AppReducer()
        )
        
        let address = "t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po"
        store.send(.home(.walletEvents(.replyTo(address))))
        
        if let url = URL(string: "zcash:\(address)") {
            store.receive(.deeplink(url))
        }
    }
}
