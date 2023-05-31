//
//  ReviewRequestTestKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 3.4.2023.
//

import ComposableArchitecture
import XCTestDynamicOverlay

extension ReviewRequestClient: TestDependencyKey {
    public static let testValue = Self(
        canRequestReview: XCTUnimplemented("\(Self.self).canRequestReview", placeholder: false),
        foundTransactions: XCTUnimplemented("\(Self.self).foundTransactions"),
        reviewRequested: XCTUnimplemented("\(Self.self).reviewRequested"),
        syncFinished: XCTUnimplemented("\(Self.self).syncFinished")
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
