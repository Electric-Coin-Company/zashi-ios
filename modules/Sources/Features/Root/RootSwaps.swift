//
//  RootSwaps.swift
//  modules
//
//  Created by Lukáš Korba on 14.10.2025.
//

import Combine
import ComposableArchitecture
import Foundation
import ZcashLightClientKit
import Generated
import Models

extension Root {
    public func swapsReduce() -> Reduce<Root.State, Root.Action> {
        Reduce { state, action in
            switch action {
            case .home(.transactionList(.transactionOnAppear(let txId))),
                .transactionsCoordFlow(.transactionsManager(.transactionOnAppear(let txId))):
                if let candidate = state.transactions[id: txId] {
                    state.autoUpdateSwapCandidates.append(candidate)
//                    print("__LD on \(txId) \(state.autoUpdateSwapCandidates.ids.count)")
                }
                return .send(.attemptToCheckSwapStatus)

//            case .home(.transactionList(.transactionOnDisappear(let txId))),
//                .transactionsCoordFlow(.transactionsManager(.transactionOnDisappear(let txId))):
//                if let candidate = state.transactions[id: txId] {
//                    state.autoUpdateSwapCandidates.remove(candidate)
////                    print("__LD off \(txId) \(state.autoUpdateSwapCandidates.ids.count)")
//                }
//                return .none

            case .attemptToCheckSwapStatus:
//                print("__LD attemptToCheckSwapStatus \(state.autoUpdateSwapCandidates.count)")
                guard !state.autoUpdateSwapCandidates.isEmpty else {
                    return .none
                }
                let now = Date.now.timeIntervalSince1970
                let diff = now - state.autoUpdateLatestAttemptedTimestamp
                
                // schedule next check
                if diff < 5.0 {
                    return .run { send in
                        let waitTIme = UInt64.random(in: 5_000_000_000...15_000_000_000)
                        try? await Task.sleep(nanoseconds: waitTIme)
                        await send(.attemptToCheckSwapStatus)
                    }
                }
                state.autoUpdateLatestAttemptedTimestamp = now
                
                // check the status
                guard state.autoUpdateCandidate == nil else {
                    return .none
                }
                if let candidate = state.autoUpdateSwapCandidates.first {
                    state.autoUpdateCandidate = candidate
                    return .run { send in
                        if let swapDetails = try? await swapAndPay.status(candidate.address, candidate.isSwapToZec) {
                            await send(.autoUpdateCandidatesSwapDetails(swapDetails))
//                            print("__LD \(swapDetails.status)")
                        }
                    }
                }
                return .send(.attemptToCheckSwapStatus)
                
            case .autoUpdateCandidatesSwapDetails(let swapDetails):
                guard let candidate = state.autoUpdateCandidate else {
                    return .none
                }
                
                if candidate.isPending && !swapDetails.status.isPending {
                    state.autoUpdateSwapDetails = swapDetails
                    return .send(.compareAndUpdateMetadataOfSwap)
                }
                state.autoUpdateCandidate = nil
                return .send(.attemptToCheckSwapStatus)
                
            case .compareAndUpdateMetadataOfSwap:
                guard let candidatesId = state.autoUpdateCandidate?.id else {
                    return .none
                }
                guard var candidate = state.transactions[id: candidatesId], let zAddress = candidate.zAddress else {
                    return .none
                }

                let umSwapId = userMetadataProvider.swapDetailsForTransaction(zAddress)
                guard var umSwapId, let swapDetails = state.autoUpdateSwapDetails else {
                    return .none
                }
                
                var needsUpdate = false
                
                // from asset
                if let fromAsset = state.swapAssets.filter({ $0.assetId == swapDetails.fromAsset }).first {
                    if umSwapId.fromAsset != fromAsset.id {
                        needsUpdate = true
                        umSwapId.fromAsset = fromAsset.id
                    }
                }
                // to asset
                if let toAsset = state.swapAssets.filter({ $0.assetId == swapDetails.toAsset }).first {
                    if umSwapId.toAsset != toAsset.id {
                        needsUpdate = true
                        umSwapId.toAsset = toAsset.id
                    }
                }
                // swap vs. pay update
                if umSwapId.exactInput != swapDetails.isSwap {
                    needsUpdate = true
                    umSwapId.exactInput = swapDetails.isSwap
                }
                // amountOutFormatted
                if let amountOutFormattedValue = swapDetails.amountOutFormatted, swapDetails.isSwapToZec {
                    let amountOutFormatted = "\(amountOutFormattedValue)"
                    if umSwapId.amountOutFormatted != amountOutFormatted {
                        needsUpdate = true
                        umSwapId.amountOutFormatted = amountOutFormatted
                        if let localeString = amountOutFormatted.localeString {
                            candidate.swapToZecAmount = localeString
                        }
                    }
                }
                // status
                if umSwapId.status != swapDetails.status.rawName {
                    needsUpdate = true
                    umSwapId.status = swapDetails.status.rawName
                }
                // update of metadata needed
                state.autoUpdateCandidate = nil
                state.autoUpdateSwapDetails = nil
                if let account = state.selectedWalletAccount?.account, needsUpdate {
                    userMetadataProvider.update(umSwapId)
                    try? userMetadataProvider.store(account)
                    candidate.checkAndUpdateWith(umSwapId)
                    state.$transactions.withLock { $0[id: candidate.id] = candidate }
                    state.autoUpdateSwapCandidates.remove(candidate)
//                    print("__LD off2 \(candidate.id) \(state.autoUpdateSwapCandidates.ids.count)")
                }
                return .send(.attemptToCheckSwapStatus)

            default: return .none
            }
        }
    }
}
