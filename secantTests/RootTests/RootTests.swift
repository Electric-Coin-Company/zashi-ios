//
//  RootTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 12.04.2022.
//

import XCTest
@testable import secant_testnet
import ComposableArchitecture

class RootTests: XCTestCase {
    static let testScheduler = DispatchQueue.test

    func testWalletInitializationState_Uninitialized() throws {
        let walletState = RootReducer.walletInitializationState(
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

        let walletState = RootReducer.walletInitializationState(
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

        let walletState = RootReducer.walletInitializationState(
            databaseFiles: .live(databaseFiles: DatabaseFiles(fileManager: wfmMock)),
            walletStorage: .noOp,
            zcashSDKEnvironment: .testnet
        )

        XCTAssertEqual(walletState, .uninitialized)
    }
    
    func testWalletInitializationState_FilesMissing() throws {
        let wfmMock = FileManagerClient(
            url: { _, _, _, _ in .emptyURL },
            fileExists: { _ in return false },
            removeItem: { _ in }
        )

        var walletStorage = WalletStorageClient.noOp
        walletStorage.areKeysPresent = { true }
        
        let walletState = RootReducer.walletInitializationState(
            databaseFiles: .live(databaseFiles: DatabaseFiles(fileManager: wfmMock)),
            walletStorage: walletStorage,
            zcashSDKEnvironment: .testnet
        )

        XCTAssertEqual(walletState, .filesMissing)
    }
    
    func testWalletInitializationState_Initialized() throws {
        let wfmMock = FileManagerClient(
            url: { _, _, _, _ in .emptyURL },
            fileExists: { _ in return true },
            removeItem: { _ in }
        )

        var walletStorage = WalletStorageClient.noOp
        walletStorage.areKeysPresent = { true }
        
        let walletState = RootReducer.walletInitializationState(
            databaseFiles: .live(databaseFiles: DatabaseFiles(fileManager: wfmMock)),
            walletStorage: walletStorage,
            zcashSDKEnvironment: .testnet
        )

        XCTAssertEqual(walletState, .initialized)
    }

    func testRespondToWalletInitializationState_Uninitialized() throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: RootReducer()
        ) {
            $0.mainQueue = Self.testScheduler.eraseToAnyScheduler()
        }

        store.send(.initialization(.respondToWalletInitializationState(.uninitialized)))
        
        Self.testScheduler.advance(by: 3)

        store.receive(.destination(.updateDestination(.onboarding))) {
            $0.destinationState.destination = .onboarding
            $0.appInitializationState = .uninitialized
        }
    }

    func testRespondToWalletInitializationState_KeysMissing() throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: RootReducer()
        )
        
        store.send(.initialization(.respondToWalletInitializationState(.keysMissing))) { state in
            state.appInitializationState = .keysMissing
        }
    }

    func testRespondToWalletInitializationState_FilesMissing() throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: RootReducer()
        ) { dependencies in
            dependencies.walletStorage = .noOp
            dependencies.walletStorage.exportWallet = { throw "export failed" }
        }

        store.send(.initialization(.respondToWalletInitializationState(.filesMissing))) { state in
            state.appInitializationState = .filesMissing
        }

        store.receive(.initialization(.initializeSDK)) { state in
            // failed is expected because environment is throwing errors
            state.appInitializationState = .failed
        }

        store.receive(.initialization(.checkBackupPhraseValidation))
    }

    func testRespondToWalletInitializationState_Initialized() throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: RootReducer()
        ) { dependencies in
            dependencies.walletStorage = .noOp
            dependencies.walletStorage.exportWallet = { throw "export failed" }
        }

        store.send(.initialization(.respondToWalletInitializationState(.initialized)))

        store.receive(.initialization(.initializeSDK)) { state in
            // failed is expected because environment is throwing errors
            state.appInitializationState = .failed
        }

        store.receive(.initialization(.checkBackupPhraseValidation))
    }
    
    func testWalletEventReplyTo_validAddress() throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: RootReducer()
        )
        
        let address = "t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po"
        store.send(.home(.walletEvents(.replyTo(address))))
        
        if let url = URL(string: "zcash:\(address)") {
            store.receive(.destination(.deeplink(url)))
        }
    }
}
