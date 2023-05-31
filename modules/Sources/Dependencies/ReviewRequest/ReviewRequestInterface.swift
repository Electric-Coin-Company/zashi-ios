//
//  ReviewRequestInterface.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 3.4.2023.
//

import ComposableArchitecture

extension DependencyValues {
    public var reviewRequest: ReviewRequestClient {
        get { self[ReviewRequestClient.self] }
        set { self[ReviewRequestClient.self] = newValue }
    }
}

public struct ReviewRequestClient {
    public let canRequestReview: () -> Bool
    public let foundTransactions: () -> Void
    public let reviewRequested: () -> Void
    public let syncFinished: () -> Void
}
