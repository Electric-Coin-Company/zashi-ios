//
//  ImportWalletSnapshotTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 13.06.2022.
//

import XCTest
import ComposableArchitecture
import ImportWallet
@testable import secant_testnet

class ImportWalletSnapshotTests: XCTestCase {
    func testImportWalletSnapshot() throws {
        let store = ImportWalletStore(
            initialState: .placeholder,
            reducer: ImportWalletReducer(saplingActivationHeight: 0)
        )
        
        addAttachments(ImportWalletView(store: store))
    }
    
    func testImportBirthdaySnapshot() throws {
        let store = ImportWalletStore(
            initialState: .placeholder,
            reducer: ImportWalletReducer(saplingActivationHeight: 0)
        )
        
        addAttachments(ImportBirthdayView(store: store))
    }
}
