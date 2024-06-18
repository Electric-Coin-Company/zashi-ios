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

@MainActor
class RootTests: XCTestCase {
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

    @MainActor func testRespondToWalletInitializationState_Uninitialized() async throws {
        let store = TestStore(
            initialState: .initial
        ) {
            RootReducer()
        }

        store.dependencies.mainQueue = .immediate
        store.dependencies.crashReporter = .noOp
        store.dependencies.walletStorage = .noOp
        store.dependencies.databaseFiles = .noOp

        await store.send(.initialization(.respondToWalletInitializationState(.uninitialized)))

        await store.receive(.destination(.updateDestination(.onboarding))) { state in
            state.destinationState.destination = .onboarding
            state.appInitializationState = .uninitialized
        }
        
        await store.finish()
    }

    func testRespondToWalletInitializationState_KeysMissing() async throws {
        let store = TestStore(
            initialState: .initial
        ) {
            RootReducer()
        }

        store.dependencies.mainQueue = .immediate
        store.dependencies.crashReporter = .noOp
        store.dependencies.walletStorage = .noOp
        store.dependencies.databaseFiles = .noOp

        await store.send(.initialization(.respondToWalletInitializationState(.keysMissing))) { state in
            state.appInitializationState = .keysMissing
        }
        
        await store.receive(.destination(.updateDestination(.onboarding))) { state in
            state.destinationState.internalDestination = .onboarding
            state.destinationState.previousDestination = .welcome
        }
        
        await store.finish()
    }

    func testRespondToWalletInitializationState_FilesMissing() async throws {
        let walletStorageError: Error = "export failed"
        let zcashError = ZcashError.unknown(walletStorageError)

        let store = TestStore(
            initialState: .initial
        ) {
            RootReducer()
        }
        
        store.dependencies.walletStorage = .noOp
        store.dependencies.walletStorage.exportWallet = { throw zcashError }
        store.dependencies.walletStatusPanel = .noOp
        store.dependencies.userDefaults = .noOp

        await store.send(.initialization(.respondToWalletInitializationState(.filesMissing))) { state in
            state.appInitializationState = .filesMissing
            state.isRestoringWallet = true
        }
        
        await store.receive(.initialization(.initializeSDK(.restoreWallet)))

        await store.receive(.initialization(.checkBackupPhraseValidation))

        await store.receive(.initialization(.initializationFailed(zcashError))) { state in
            state.appInitializationState = .failed
            state.alert = AlertState.initializationFailed(zcashError)
        }
        
        await store.receive(.initialization(.initializationFailed(zcashError)))
        
        await store.finish()
    }

    func testRespondToWalletInitializationState_Initialized() async throws {
        let walletStorageError: Error = "export failed"
        let zcashError = ZcashError.unknown(walletStorageError)

        let store = TestStore(
            initialState: .initial
        ) {
            RootReducer()
        }
        
        store.dependencies.walletStorage = .noOp
        store.dependencies.walletStorage.exportWallet = { throw walletStorageError }
        store.dependencies.userDefaults = .noOp

        await store.send(.initialization(.respondToWalletInitializationState(.initialized)))

        await store.receive(.initialization(.initializeSDK(.existingWallet)))

        await store.receive(.initialization(.checkBackupPhraseValidation))
        
        await store.receive(.initialization(.initializationFailed(zcashError))) { state in
            state.appInitializationState = .failed
            state.alert = AlertState.initializationFailed(zcashError)
        }
        
        await store.receive(.initialization(.initializationFailed(zcashError)))

        await store.finish()
    }
    
    func testInitializationSuccessfullyDone() async throws {
        let store = TestStore(
            initialState: .initial
        ) {
            RootReducer()
        }
        
        store.dependencies.mainQueue = .immediate
        store.dependencies.sdkSynchronizer = .noOp
        store.dependencies.autolockHandler = .noOp
        
        // swiftlint:disable line_length
        let uAddress = try UnifiedAddress(
            encoding: "utest1zkkkjfxkamagznjr6ayemffj2d2gacdwpzcyw669pvg06xevzqslpmm27zjsctlkstl2vsw62xrjktmzqcu4yu9zdhdxqz3kafa4j2q85y6mv74rzjcgjg8c0ytrg7dwyzwtgnuc76h", network: .testnet
        )

        await store.send(.initialization(.initializationSuccessfullyDone(uAddress))) { state in
            state.tabsState.addressDetailsState.uAddress = uAddress
        }

        await store.receive(.initialization(.registerForSynchronizersUpdate))

        await store.send(.cancelAllRunningEffects)
        
        await store.finish()
    }
}
