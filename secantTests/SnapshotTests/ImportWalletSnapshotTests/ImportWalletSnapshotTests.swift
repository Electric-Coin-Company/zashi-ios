//
//  ImportWalletSnapshotTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 13.06.2022.
//

import XCTest
@testable import secant_testnet
import ComposableArchitecture

class ImportWalletSnapshotTests: XCTestCase {
    func testImportWalletSnapshot() throws {
        let store = ImportWalletStore(
            initialState: .placeholder,
            reducer: ImportWalletReducer()
        )
        
        addAttachments(ImportWalletView(store: store))
    }
}
