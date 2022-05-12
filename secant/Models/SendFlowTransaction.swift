//
//  Transaction.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 12.05.2022.
//

import Foundation

/// Simple model that holds data throughout the `SendFlow` feature
struct SendFlowTransaction: Equatable {
    var amount: Int64
    var memo: String
    var toAddress: String
}

extension SendFlowTransaction {
    static var placeholder: Self {
        .init(
            amount: 0,
            memo: "",
            toAddress: ""
        )
    }
}
