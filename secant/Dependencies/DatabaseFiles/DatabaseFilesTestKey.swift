//
//  DatabaseFilesTestKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 11.11.2022.
//

import ComposableArchitecture
import XCTestDynamicOverlay

extension DatabaseFilesClient: TestDependencyKey {
    static let testValue = Self(
        documentsDirectory: XCTUnimplemented("\(Self.self).documentsDirectory"),
        cacheDbURLFor: XCTUnimplemented("\(Self.self).cacheDbURLFor"),
        dataDbURLFor: XCTUnimplemented("\(Self.self).dataDbURLFor"),
        outputParamsURLFor: XCTUnimplemented("\(Self.self).outputParamsURLFor"),
        pendingDbURLFor: XCTUnimplemented("\(Self.self).pendingDbURLFor"),
        spendParamsURLFor: XCTUnimplemented("\(Self.self).spendParamsURLFor"),
        areDbFilesPresentFor: XCTUnimplemented("\(Self.self).areDbFilesPresentFor", placeholder: false),
        nukeDbFilesFor: XCTUnimplemented("\(Self.self).nukeDbFilesFor")
    )
}
