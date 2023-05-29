//
//  DatabaseFilesTestKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 11.11.2022.
//

import Foundation
import ComposableArchitecture
import XCTestDynamicOverlay
import Utils

extension DatabaseFilesClient: TestDependencyKey {
    public static let testValue = Self(
        documentsDirectory: XCTUnimplemented("\(Self.self).documentsDirectory", placeholder: .emptyURL),
        fsBlockDbRootFor: XCTUnimplemented("\(Self.self).fsBlockDbRootFor", placeholder: .emptyURL),
        cacheDbURLFor: XCTUnimplemented("\(Self.self).cacheDbURLFor", placeholder: .emptyURL),
        dataDbURLFor: XCTUnimplemented("\(Self.self).dataDbURLFor", placeholder: .emptyURL),
        outputParamsURLFor: XCTUnimplemented("\(Self.self).outputParamsURLFor", placeholder: .emptyURL),
        pendingDbURLFor: XCTUnimplemented("\(Self.self).pendingDbURLFor", placeholder: .emptyURL),
        spendParamsURLFor: XCTUnimplemented("\(Self.self).spendParamsURLFor", placeholder: .emptyURL),
        areDbFilesPresentFor: XCTUnimplemented("\(Self.self).areDbFilesPresentFor", placeholder: false)
    )
}

extension DatabaseFilesClient {
    public static let noOp = Self(
        documentsDirectory: { .emptyURL },
        fsBlockDbRootFor: { _ in .emptyURL },
        cacheDbURLFor: { _ in .emptyURL },
        dataDbURLFor: { _ in .emptyURL },
        outputParamsURLFor: { _ in .emptyURL },
        pendingDbURLFor: { _ in .emptyURL },
        spendParamsURLFor: { _ in .emptyURL },
        areDbFilesPresentFor: { _ in false }
    )
}
