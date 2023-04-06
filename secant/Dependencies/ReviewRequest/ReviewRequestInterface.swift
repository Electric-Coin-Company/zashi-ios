//
//  ReviewRequestInterface.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 3.4.2023.
//

import ComposableArchitecture

extension DependencyValues {
    var reviewRequest: ReviewRequestClient {
        get { self[ReviewRequestClient.self] }
        set { self[ReviewRequestClient.self] = newValue }
    }
}

struct ReviewRequestClient {
    let canRequestReview: () -> Bool
    let foundTransactions: () async -> Void
    let reviewRequested: () async -> Void
    let syncFinished: () async -> Void
}
