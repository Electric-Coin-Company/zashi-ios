//
//  DatabaseFilesTestKey.swift
//  Zashi
//
//  Created by Lukáš Korba on 11.11.2022.
//

import Foundation
import ComposableArchitecture
import XCTestDynamicOverlay
import Utils

extension DatabaseFilesClient: TestDependencyKey {
    public static let testValue = Self(
        documentsDirectory: unimplemented("\(Self.self).documentsDirectory", placeholder: .emptyURL),
        fsBlockDbRootFor: unimplemented("\(Self.self).fsBlockDbRootFor", placeholder: .emptyURL),
        cacheDbURLFor: unimplemented("\(Self.self).cacheDbURLFor", placeholder: .emptyURL),
        dataDbURLFor: unimplemented("\(Self.self).dataDbURLFor", placeholder: .emptyURL),
        outputParamsURLFor: unimplemented("\(Self.self).outputParamsURLFor", placeholder: .emptyURL),
        pendingDbURLFor: unimplemented("\(Self.self).pendingDbURLFor", placeholder: .emptyURL),
        spendParamsURLFor: unimplemented("\(Self.self).spendParamsURLFor", placeholder: .emptyURL),
        toDirURLFor: unimplemented("\(Self.self).toDirURLFor", placeholder: .emptyURL),
        areDbFilesPresentFor: unimplemented("\(Self.self).areDbFilesPresentFor", placeholder: false)
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
        toDirURLFor: { _ in .emptyURL },
        areDbFilesPresentFor: { _ in false }
    )
}
