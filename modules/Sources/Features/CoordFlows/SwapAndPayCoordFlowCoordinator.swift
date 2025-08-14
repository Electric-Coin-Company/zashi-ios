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

                // MARK: - Address Book

            case .path(.element(id: _, action: .addressBook(.editId(let address)))):
                let _ = state.path.popLast()
                audioServices.systemSoundVibrate()
                return .send(.swapAndPay(.addressBookContactSelected(address)))

            case .path(.element(id: _, action: .addressBook(.addManualButtonTapped))):
                var addressBookState = AddressBook.State.initial
                addressBookState.isAddressFocused = true
                addressBookState.isSwapFlowActive = true
                state.path.append(.addressBookContact(addressBookState))
                return .none

            case .path(.element(id: _, action: .addressBook(.scanButtonTapped))):
                var scanState = Scan.State.initial
                scanState.checkers = [.swapStringScanChecker]
                state.path.append(.scan(scanState))
                return .none

                // MARK: - Address Book Contact

            case .path(.element(id: _, action: .addressBookContact(.dismissAddContactRequired))):
                for element in state.path {
                    if element.is(\.scan) {
                        let _ = state.path.popLast()
                        break
                    }
                }
                let _ = state.path.popLast()
                if state.path.ids.isEmpty {
                    return .send(.swapAndPay(.checkSelectedContact))
                } else if let last = state.path.ids.last {
                    return .send(.path(.element(id: last, action: .swapAndPayForm(.checkSelectedContact))))
                }
                return .none

                // MARK: - Keystone
                
            case .swapAndPay(.confirmWithKeystoneTapped):
                var sendConfirmationState = SendConfirmation.State.initial
                sendConfirmationState.proposal = state.swapAndPayState.proposal
                state.path.append(.confirmWithKeystone(sendConfirmationState))
                if let last = state.path.ids.last {
                    return .send(.path(.element(id: last, action: .confirmWithKeystone(.resolvePCZT))))
                }
                return .none

            case .path(.element(id: _, action: .confirmWithKeystone(.getSignatureTapped))):
                var scanState = Scan.State.initial
                scanState.checkers = [.keystonePCZTScanChecker]
                state.path.append(.scan(scanState))
                return .none

            case .path(.element(id: _, action: .scan(.foundPCZT(let pcztWithSigs)))):
                for (id, element) in zip(state.path.ids, state.path) {
                    if case .confirmWithKeystone(let sendConfirmationState) = element {
                        state.path.append(.sending(sendConfirmationState))
                        return .send(.path(.element(id: id, action: .confirmWithKeystone(.foundPCZT(pcztWithSigs)))))
                    }
                }
                return .none

            case .path(.element(id: _, action: .confirmWithKeystone(.updateResult(let result)))):
                for (id, element) in zip(state.path.ids, state.path) {
                    if case .confirmWithKeystone(let sendConfirmationState) = element {
                        let provider = state.provider
                        return .run { send in
                            await send(.updateTxIdToExpand(sendConfirmationState.txIdToExpand))
                            await send(
                                .updateFailedData(
                                    sendConfirmationState.failedCode,
                                    sendConfirmationState.failedDescription ?? "",
                                    sendConfirmationState.failedPcztMsg
                                )
                            )

                            switch result {
                            case .success:
                                if let txId = sendConfirmationState.txIdToExpand {
                                    userMetadataProvider.markTransactionAsSwapFor(txId, provider)
                                }
                                await send(.updateResult(.success))
                            case .failure:
                                await send(.updateResult(.failure))
                            case .resubmission:
                                await send(.updateResult(.resubmission))
                            default: return
                            }
                        }
                    }
                }
                return .none
                
            case .path(.element(id: _, action: .confirmWithKeystone(.pcztSendFailed(let error)))):
                for element in state.path.reversed() {
                    if element.is(\.sending) {
                        for (id, element2) in zip(state.path.ids, state.path) {
                            if element2.is(\.confirmWithKeystone) {
                                return .send(.path(.element(id: id, action: .confirmWithKeystone(.sendFailed(error?.toZcashError(), true)))))
                            }
                        }
                        break
                    } else if element.is(\.scan) || element.is(\.confirmWithKeystone) {
                        for element2 in state.path {
                            if case .confirmWithKeystone(let sendConfirmationState) = element2 {
                                state.path.append(.preSendingFailure(sendConfirmationState))
                            }
                        }
                        break
                    }
                }
                return .none

                // MARK: - Scan
                
            case .path(.element(id: _, action: .scan(.foundString(let address)))):
                // handle direct scan from the form
                if state.path.count == 1 {
                    let _ = state.path.removeLast()
                    audioServices.systemSoundVibrate()
                    state.swapAndPayState.address = address
                } else {
                    // handle scan inside add a new contact flow
                    audioServices.systemSoundVibrate()
                    var addressBookState = AddressBook.State.initial
                    addressBookState.address = address
                    addressBookState.isNameFocused = true
                    addressBookState.isSwapFlowActive = true
                    state.path.append(.addressBookContact(addressBookState))
                }
                return .none

            case .path(.element(id: _, action: .scan(.cancelTapped))):
                let _ = state.path.popLast()
                return .none
                
                // MARK: - Send Confirmation
                
            case .path(.element(id: _, action: .sending(.sendingScreenOnAppear))):
                state.sendingScreenOnAppearTimestamp = Date().timeIntervalSince1970
                return .none

            case .path(.element(id: _, action: .sendResultSuccess(.checkStatusTapped))),
                    .path(.element(id: _, action: .sendResultFailure(.viewTransactionTapped))),
                    .path(.element(id: _, action: .sendResultResubmission(.viewTransactionTapped))):
                if let txid = state.txIdToExpand {
                    if let index = state.transactions.index(id: txid) {
                        var transactionDetailsState = TransactionDetails.State.initial
                        transactionDetailsState.transaction = state.transactions[index]
                        transactionDetailsState.isCloseButtonRequired = true
                        state.path.append(.transactionDetails(transactionDetailsState))
                    }
                }
                return .none

                // MARK: - Self

            case .storeLastUsedAsset:
                guard let selectedAsset = state.swapAndPayState.selectedAsset else {
                    return .none
                }
                userMetadataProvider.addLastUsedSwapAsset(selectedAsset.id)
                if let account = state.selectedWalletAccount?.account {
                    try? userMetadataProvider.store(account)
                }
                return .none
                
            case .swapAndPay(.enableSwapExperience):
                state.isSwapExperience.toggle()
                return .none

            case let .updateFailedData(code, desc, pcztMsg):
                state.failedCode = code
                state.failedDescription = desc
                #if DEBUG
                state.failedPcztMsg = pcztMsg
                #endif
                return .none

            case .swapAndPay(.addressBookTapped),
                    .path(.element(id: _, action: .swapAndPayForm(.addressBookTapped))):
                var addressBookState = AddressBook.State.initial
                addressBookState.isSwapFlowActive = true
                addressBookState.isInSelectMode = true
                state.path.append(.addressBook(addressBookState))
                return .none

            case .swapAndPay(.notInAddressBookButtonTapped(let address)),
                    .path(.element(id: _, action: .swapAndPayForm(.notInAddressBookButtonTapped(let address)))):
                var addressBookState = AddressBook.State.initial
                addressBookState.isSwapFlowActive = true
                addressBookState.address = address
                addressBookState.isNameFocused = true
                state.path.append(.addressBookContact(addressBookState))
                return .none

            case .backButtonTapped:
                return .send(.swapAndPay(.backButtonTapped(state.isSwapInFlight)))
                
            case .swapAndPay(.scanTapped),
                    .path(.element(id: _, action: .swapAndPayForm(.scanTapped))):
                var scanState = Scan.State.initial
                scanState.checkers = [.swapStringScanChecker]
                state.path.append(.scan(scanState))
                return .none
                
            case .swapAndPay(.confirmButtonTapped),
                    .path(.element(id: _, action: .swapAndPayForm(.confirmButtonTapped))):
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
                let provider = state.provider
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
                            if let txId = txIds.last {
                                // store the txId into metadata
                                userMetadataProvider.markTransactionAsSwapFor(txId, provider)
                            }
                            await send(.sendDone)
                            if let txId = txIds.last {
                                // inform service to speed up the transaction processing
                                try? await swapAndPay.submitDepositTxId(txId, depositAddress)
                            }
                        }
                    } catch {
                        await send(.sendFailed(error.toZcashError(), true))
                    }
                }

            case .sendDone:
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
                switch result {
                case .failure:
                    state.path.append(.sendResultFailure(sendConfirmationState))
                    break
                case .resubmission:
                    state.path.append(.sendResultResubmission(sendConfirmationState))
                    break
                case .success:
                    state.path.append(.sendResultSuccess(sendConfirmationState))
                    return .send(.storeLastUsedAsset)
                default: break
                }
                return .none

            // MARK: - Self Opt-in
                
            case .swapAndPay(.skipOptInTapped):
                state.swapAndPayState.optionOneChecked = false
                state.swapAndPayState.optionTwoChecked = false
                state.path.append(.swapAndPayOptInForced(state.swapAndPayState))
                return .none

            case .swapAndPay(.confirmOptInTapped):
                state.path.append(.swapAndPayForm(state.swapAndPayState))
                return .send(.swapAndPay(.refreshSwapAssets))

            case .path(.element(id: _, action: .swapAndPayOptInForced(.confirmForcedOptInTapped))):
                state.path.append(.swapAndPayForm(state.swapAndPayState))
                return .send(.swapAndPay(.refreshSwapAssets))

            case .path(.element(id: _, action: .swapAndPayOptInForced(.goBackForcedOptInTapped))):
                let _ = state.path.popLast()
                return .none

            case .path(.element(id: _, action: .swapAndPayForm(.internalBackButtonTapped))):
                return .send(.swapAndPay(.backButtonTapped(state.isSwapInFlight)))

            default: return .none
            }
        }
    }
}
