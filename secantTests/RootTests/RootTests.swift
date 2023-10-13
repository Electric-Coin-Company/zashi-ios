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
import Root
@testable import secant_testnet

class RootTests: XCTestCase {
    static let testScheduler = DispatchQueue.test

    func testWalletInitializationState_Uninitialized() throws {
        let walletState = RootReducer.walletInitializationState(
            databaseFiles: .noOp,
            walletStorage: .noOp,
            zcashNetwork: ZcashNetworkBuilder.network(for: .testnet)
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
            zcashNetwork: ZcashNetworkBuilder.network(for: .testnet)
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
            zcashNetwork: ZcashNetworkBuilder.network(for: .testnet)
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
            zcashNetwork: ZcashNetworkBuilder.network(for: .testnet)
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
            zcashNetwork: ZcashNetworkBuilder.network(for: .testnet)
        )

        XCTAssertEqual(walletState, .initialized)
    }

    func testRespondToWalletInitializationState_Uninitialized() throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: RootReducer(tokenName: "ZEC", zcashNetwork: ZcashNetworkBuilder.network(for: .testnet))
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
            reducer: RootReducer(tokenName: "ZEC", zcashNetwork: ZcashNetworkBuilder.network(for: .testnet))
        )
        
        store.send(.initialization(.respondToWalletInitializationState(.keysMissing))) { state in
            state.appInitializationState = .keysMissing
            state.alert = AlertState.walletStateFailed(.keysMissing)
        }
    }

    func testRespondToWalletInitializationState_FilesMissing() throws {
        let walletStorageError: Error = "export failed"
        let zcashError = ZcashError.unknown(walletStorageError)

        let store = TestStore(
            initialState: .placeholder,
            reducer: RootReducer(tokenName: "ZEC", zcashNetwork: ZcashNetworkBuilder.network(for: .testnet))
        )
        
        store.dependencies.walletStorage = .noOp
        store.dependencies.walletStorage.exportWallet = { throw walletStorageError }

        store.send(.initialization(.respondToWalletInitializationState(.filesMissing))) { state in
            state.appInitializationState = .filesMissing
        }
        
        store.receive(.initialization(.initializeSDK(.existingWallet)))

        store.receive(.initialization(.checkBackupPhraseValidation)) { state in
            // failed is expected because environment is throwing errors
            state.appInitializationState = .failed
            state.alert = AlertState.cantLoadSeedPhrase()
        }

        store.receive(.initialization(.initializationFailed(zcashError))) { state in
            state.alert = AlertState.initializationFailed(zcashError)
        }
    }

    func testRespondToWalletInitializationState_Initialized() throws {
        let walletStorageError: Error = "export failed"
        let zcashError = ZcashError.unknown(walletStorageError)

        let store = TestStore(
            initialState: .placeholder,
            reducer: RootReducer(tokenName: "ZEC", zcashNetwork: ZcashNetworkBuilder.network(for: .testnet))
        )
        
        store.dependencies.walletStorage = .noOp
        store.dependencies.walletStorage.exportWallet = { throw walletStorageError }

        store.send(.initialization(.respondToWalletInitializationState(.initialized)))

        store.receive(.initialization(.initializeSDK(.existingWallet)))

        store.receive(.initialization(.checkBackupPhraseValidation)) { state in
            // failed is expected because environment is throwing errors
            state.appInitializationState = .failed
            state.alert = AlertState.cantLoadSeedPhrase()
        }
        
        store.receive(.initialization(.initializationFailed(zcashError))) { state in
            state.alert = AlertState.initializationFailed(zcashError)
        }
    }
    
    func testInitializationSuccessfullyDone() throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: RootReducer(tokenName: "ZEC", zcashNetwork: ZcashNetworkBuilder.network(for: .testnet))
        )
        
        // swiftlint:disable line_length
        let uAddress = try UnifiedAddress(encoding: "utest1zkkkjfxkamagznjr6ayemffj2d2gacdwpzcyw669pvg06xevzqslpmm27zjsctlkstl2vsw62xrjktmzqcu4yu9zdhdxqz3kafa4j2q85y6mv74rzjcgjg8c0ytrg7dwyzwtgnuc76h", network: .testnet
        )
        
        store.send(.initialization(.initializationSuccessfullyDone(uAddress))) { state in
            state.tabsState.addressDetailsState.uAddress = uAddress
        }
    }
}
