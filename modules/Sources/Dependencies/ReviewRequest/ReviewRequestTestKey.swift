//
//  ReviewRequestTestKey.swift
//  Zashi
//
//  Created by Lukáš Korba on 3.4.2023.
//

import ComposableArchitecture
import XCTestDynamicOverlay

extension ReviewRequestClient: TestDependencyKey {
    public static let testValue = Self(
        canRequestReview: unimplemented("\(Self.self).canRequestReview", placeholder: false),
        foundTransactions: unimplemented("\(Self.self).foundTransactions", placeholder: {}()),
        reviewRequested: unimplemented("\(Self.self).reviewRequested", placeholder: {}()),
        syncFinished: unimplemented("\(Self.self).syncFinished", placeholder: {}())
    )
}

extension ReviewRequestClient {
    public static let noOp = Self(
        canRequestReview: { false },
        foundTransactions: { },
        reviewRequested: { },
        syncFinished: { }
    )
}
