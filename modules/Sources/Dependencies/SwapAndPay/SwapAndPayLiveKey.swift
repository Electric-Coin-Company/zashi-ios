//
//  SwapAndPayLiveKey.swift
//  Zashi
//
//  Created by Lukáš Korba on 05-15-2025.
//

import Foundation
import Network
import Combine
import ComposableArchitecture

extension SwapAndPayClient: DependencyKey {
    public static let liveValue = Self(
        submitDepositTxId: { txId, depositAddress in
            try await Near1Click.liveValue.submitDepositTxId(
                txId,
                depositAddress
            )
        },
        swapAssets: {
            try await Near1Click.liveValue.swapAssets()
        },
        quote: { dry, isSwapToZec, exactInput, slippageTolerance, zecAsset, toAsset, refundTo, destination, amount in
            try await Near1Click.liveValue.quote(
                dry,
                isSwapToZec,
                exactInput,
                slippageTolerance,
                zecAsset,
                toAsset,
                refundTo,
                destination,
                amount
            )
        },
        status: { depositAddress in
            try await Near1Click.liveValue.status(depositAddress)
        }
    )
}
