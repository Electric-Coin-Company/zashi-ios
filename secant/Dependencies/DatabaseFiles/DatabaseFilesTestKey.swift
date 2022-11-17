//
//  DatabaseFilesTestKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 11.11.2022.
//

import Foundation
import ComposableArchitecture
import XCTestDynamicOverlay

extension DatabaseFilesClient: TestDependencyKey {
    static let testValue = Self(
        documentsDirectory: XCTUnimplemented("\(Self.self).documentsDirectory", placeholder: .emptyURL),
        cacheDbURLFor: XCTUnimplemented("\(Self.self).cacheDbURLFor", placeholder: .emptyURL),
        dataDbURLFor: XCTUnimplemented("\(Self.self).dataDbURLFor", placeholder: .emptyURL),
        outputParamsURLFor: XCTUnimplemented("\(Self.self).outputParamsURLFor", placeholder: .emptyURL),
        pendingDbURLFor: XCTUnimplemented("\(Self.self).pendingDbURLFor", placeholder: .emptyURL),
        spendParamsURLFor: XCTUnimplemented("\(Self.self).spendParamsURLFor", placeholder: .emptyURL),
        areDbFilesPresentFor: XCTUnimplemented("\(Self.self).areDbFilesPresentFor", placeholder: false),
        nukeDbFilesFor: XCTUnimplemented("\(Self.self).nukeDbFilesFor")
    )
}

extension URL {
    /// The `DatabaseFilesClient` API returns an instance of the URL or throws an error.
    /// In order to use placeholders for the URL we need a URL instance, hence `emptyURL` and force unwrapp.
    static let emptyURL = URL(string: "http://empty.url")!// swiftlint:disable:this force_unwrapping
}

extension DatabaseFilesClient {
    static let noOp = Self(
        documentsDirectory: { .emptyURL },
        cacheDbURLFor: { _ in .emptyURL },
        dataDbURLFor: { _ in .emptyURL },
        outputParamsURLFor: { _ in .emptyURL },
        pendingDbURLFor: { _ in .emptyURL },
        spendParamsURLFor: { _ in .emptyURL },
        areDbFilesPresentFor: { _ in false },
        nukeDbFilesFor: { _ in }
    )
}
