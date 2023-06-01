//
//  RootTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 12.04.2022.
//

import XCTest
import ComposableArchitecture
import ZcashLightClientKit
import FileManager
import DatabaseFiles
import ZcashSDKEnvironment
import WalletStorage
@testable import secant_testnet

class RootTests: XCTestCase {
    static let testScheduler = DispatchQueue.test

    func testWalletInitializationState_Uninitialized() throws {
        let walletState = RootReducer.walletInitializationState(
            databaseFiles: .noOp,
            walletStorage: .noOp
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
            walletStorage: .noOp
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
            walletStorage: .noOp
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
            walletStorage: walletStorage
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
            walletStorage: walletStorage
        )

        XCTAssertEqual(walletState, .initialized)
    }

    func testRespondToWalletInitializationState_Uninitialized() throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: RootReducer()
        )

        store.dependencies.mainQueue = Self.testScheduler.eraseToAnyScheduler()

        store.send(.initialization(.respondToWalletInitializationState(.uninitialized)))
        
        Self.testScheduler.advance(by: 3)

        store.receive(.destination(.updateDestination(.onboarding))) { state in
            state.destinationState.destination = .onboarding
            state.appInitializationState = .uninitialized
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
        
        store.receive(.alert(.root(.walletStateFailed(.keysMissing)))) { state in
            state.uniAlert = AlertState(
                title: TextState("Wallet initialisation failed."),
                message: TextState("App initialisation state: keysMissing."),
                dismissButton: .default(TextState("Ok"), action: .send(.dismissAlert))
            )
        }
    }

    func testRespondToWalletInitializationState_FilesMissing() throws {
        let walletStorageError: Error = "export failed"
        let zcashError = ZcashError.unknown(walletStorageError)

        let store = TestStore(
            initialState: .placeholder,
            reducer: RootReducer()
        )
        
        store.dependencies.walletStorage = .noOp
        store.dependencies.walletStorage.exportWallet = { throw walletStorageError }

        store.send(.initialization(.respondToWalletInitializationState(.filesMissing))) { state in
            state.appInitializationState = .filesMissing
        }
        
        store.receive(.initialization(.initializeSDK))

        store.receive(.initialization(.checkBackupPhraseValidation)) { state in
            // failed is expected because environment is throwing errors
            state.appInitializationState = .failed
        }

        store.receive(.initialization(.initializationFailed(zcashError)))

        store.receive(.alert(.root(.cantLoadSeedPhrase))) { state in
            state.uniAlert = AlertState(
                title: TextState("Wallet initialisation failed."),
                message: TextState("Can't load seed phrase from local storage."),
                dismissButton: .default(TextState("Ok"), action: .send(.dismissAlert))
            )
        }
        
        store.receive(.alert(.root(.initializationFailed(zcashError)))) { state in
            state.uniAlert = AlertState(
                title: TextState("Failed to initialize the SDK"),
                message: TextState("Error: \(zcashError.message) (code: \(zcashError.code.rawValue))"),
                dismissButton: .default(TextState("Ok"), action: .send(.dismissAlert))
            )
        }
    }

    func testRespondToWalletInitializationState_Initialized() throws {
        let walletStorageError: Error = "export failed"
        let zcashError = ZcashError.unknown(walletStorageError)

        let store = TestStore(
            initialState: .placeholder,
            reducer: RootReducer()
        )
        
        store.dependencies.walletStorage = .noOp
        store.dependencies.walletStorage.exportWallet = { throw walletStorageError }

        store.send(.initialization(.respondToWalletInitializationState(.initialized)))

        store.receive(.initialization(.initializeSDK))

        store.receive(.initialization(.checkBackupPhraseValidation)) { state in
            // failed is expected because environment is throwing errors
            state.appInitializationState = .failed
        }
        
        store.receive(.initialization(.initializationFailed(zcashError)))
        
        store.receive(.alert(.root(.cantLoadSeedPhrase))) { state in
            state.uniAlert = AlertState(
                title: TextState("Wallet initialisation failed."),
                message: TextState("Can't load seed phrase from local storage."),
                dismissButton: .default(TextState("Ok"), action: .send(.dismissAlert))
            )
        }
        
        store.receive(.alert(.root(.initializationFailed(zcashError)))) { state in
            state.uniAlert = AlertState(
                title: TextState("Failed to initialize the SDK"),
                message: TextState("Error: \(zcashError.message) (code: \(zcashError.code.rawValue))"),
                dismissButton: .default(TextState("Ok"), action: .send(.dismissAlert))
            )
        }
    }
    
    func testWalletEventReplyTo_validAddress() throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: RootReducer()
        )
        
        let address = "t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po".redacted
        store.send(.home(.walletEvents(.replyTo(address))))
        
        if let url = URL(string: "zcash:\(address)") {
            store.receive(.destination(.deeplink(url)))
        }
    }
}
