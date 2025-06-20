//
//  SwapAndPayCoordFlowCoordinator.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-05-14.
//

import Foundation
import ComposableArchitecture
import Generated

// Path
import AddressBook
import Scan
import SendConfirmation
import TransactionDetails

extension SwapAndPayCoordFlow {
    public func coordinatorReduce() -> Reduce< SwapAndPayCoordFlow.State,  SwapAndPayCoordFlow.Action> {
        Reduce { state, action in
            switch action {

                // MARK: - Scan
                
            case .path(.element(id: _, action: .scan(.foundString(let address)))):
                let _ = state.path.removeLast()
                audioServices.systemSoundVibrate()
                state.swapAndPayState.address = address
                return .none

            case .path(.element(id: _, action: .scan(.cancelTapped))):
                let _ = state.path.popLast()
                return .none
                
                // MARK: - Send Confirmation
                
            case .path(.element(id: _, action: .sending(.sendingScreenOnAppear))):
                state.sendingScreenOnAppearTimestamp = Date().timeIntervalSince1970
                return .none

            case .path(.element(id: _, action: .sendResultSuccess(.checkStatusTapped))):
//                if let txid = sendConfirmationState.txIdToExpand {
//                    if let index = state.transactions.index(id: txid) {
//                        var transactionDetailsState = TransactionDetails.State.initial
//                        transactionDetailsState.transaction = state.transactions[index]
//                        transactionDetailsState.isCloseButtonRequired = true
//                        state.path.append(.transactionDetails(transactionDetailsState))
//                    }
//                }
                return .none

                // MARK: - Self

            case .swapAndPay(.scanTapped):
                var scanState = Scan.State.initial
                scanState.checkers = [.anyStringScanChecker]
                state.path.append(.scan(scanState))
                return .none
                
            case .swapAndPay(.confirmButtonTapped):
                return .run { send in
                    guard await localAuthentication.authenticate() else {
                        await send(.stopSending)
                        return
                    }
                    
                    await send(.swapRequested)
                }

            case .swapRequested:
                guard let proposal = state.swapAndPayState.proposal else {
                    return .send(.sendFailed("missing proposal".toZcashError(), true))
                }
                guard let zip32AccountIndex = state.selectedWalletAccount?.zip32AccountIndex else {
                    return .none
                }
                
                // present sending screen
                var sendConfirmationState = SendConfirmation.State.initial
                sendConfirmationState.address = state.swapAndPayState.quote?.depositAddress ?? state.swapAndPayState.address
                sendConfirmationState.proposal = state.swapAndPayState.proposal
                sendConfirmationState.isSwap = true
                state.path.append(.sending(sendConfirmationState))
                // make the transaction
                return .run { [depositAddress = state.swapAndPayState.address] send in
                    do {
                        let storedWallet = try walletStorage.exportWallet()
                        let seedBytes = try mnemonic.toSeed(storedWallet.seedPhrase.value())
                        let network = zcashSDKEnvironment.network.networkType
                        let spendingKey = try derivationTool.deriveSpendingKey(seedBytes, zip32AccountIndex, network)

                        let result = try await sdkSynchronizer.createProposedTransactions(proposal, spendingKey)

                        switch result {
                        case .grpcFailure(let txIds):
                            await send(.updateTxIdToExpand(txIds.last))
                            await send(.sendFailed("sdkSynchronizer.createProposedTransactions-grpcFailure".toZcashError(), false))
                        case let .failure(txIds, code, description):
                            await send(.updateFailedData(code, description, ""))
                            await send(.updateTxIdToExpand(txIds.last))
                            await send(.sendFailed("sdkSynchronizer.createProposedTransactions-failure \(code) \(description)".toZcashError(), true))
                        case let .partial(txIds: txIds, _):
                            await send(.updateTxIdToExpand(txIds.last))
                        case .success(let txIds):
                            await send(.updateTxIdToExpand(txIds.last))
                            await send(.sendDone)
                            if let txId = txIds.first {
                                // inform service to speed up the transaction processing
                                try? await swapAndPay.submitDepositTxId(txId, depositAddress)
                            }
                        }
                    } catch {
                        await send(.sendFailed(error.toZcashError(), true))
                    }
                }

            case .sendDone:
//                state.isSending = false
                let diffTime = Date().timeIntervalSince1970 - state.sendingScreenOnAppearTimestamp
                let waitTimeToPresentScreen = diffTime > 2.0 ? 0.01 : 2.0 - diffTime
                return .run { send in
                    try? await mainQueue.sleep(for: .seconds(waitTimeToPresentScreen))
                    await send(.updateResult(.success))
                }
                
            case let .sendFailed(error, isFatal):
                state.failedDescription = error?.localizedDescription ?? ""
                let diffTime = Date().timeIntervalSince1970 - state.sendingScreenOnAppearTimestamp
                let waitTimeToPresentScreen = diffTime > 2.0 ? 0.01 : 2.0 - diffTime
                return .run { send in
                    try? await mainQueue.sleep(for: .seconds(waitTimeToPresentScreen))
                    await send(.updateResult(isFatal ? .failure : .resubmission))
                }
                
            case let .updateResult(result):
                var sendConfirmationState = SendConfirmation.State.initial
                sendConfirmationState.address = state.swapAndPayState.quote?.depositAddress ?? state.swapAndPayState.address
                sendConfirmationState.proposal = state.swapAndPayState.proposal
                sendConfirmationState.isSwap = true
                state.path.append(.sending(sendConfirmationState))
                switch result {
                case .failure:
                    state.path.append(.sendResultFailure(sendConfirmationState))
                    break
                case .resubmission:
                    state.path.append(.sendResultResubmission(sendConfirmationState))
                    break
                case .success:
                    state.path.append(.sendResultSuccess(sendConfirmationState))
                default: break
                }
                return .none

            default: return .none
            }
        }
    }
}
