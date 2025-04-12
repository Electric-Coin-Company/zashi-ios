//
//  RestoreWalletCoordFlowCoordinator.swift
//  Zashi
//
//  Created by Lukáš Korba on 27-03-2025.
//

import ComposableArchitecture
import Generated

// Path
import RestoreInfo
import WalletBirthday

extension RestoreWalletCoordFlow {
    public func coordinatorReduce() -> Reduce<RestoreWalletCoordFlow.State, RestoreWalletCoordFlow.Action> {
        Reduce { state, action in
            switch action {
                // MARK: - Self

            case .nextTapped:
                state.path.append(.walletBirthday(WalletBirthday.State.initial))
                return .none

            case .resolveRestoreWithBirthday(let birthday):
                do {
                    let seedPhrase = state.words.joined(separator: " ")
                    
                    // validate the seed
                    try mnemonic.isValid(seedPhrase)

                    try walletStorage.importWallet(seedPhrase, birthday, .english, false)
                    
                    // update the backup phrase validation flag
                    //try walletStorage.markUserPassedPhraseBackupTest(true)

                    state.path.append(.restoreInfo(RestoreInfo.State.initial))

                    // notify user
                    return .send(.successfullyRecovered)
                } catch {
                    return .send(.failedToRecover(error.toZcashError()))
                }

                // MARK: - Wallet Birthday

            case .path(.element(id: _, action: .walletBirthday(.helpSheetRequested))):
                state.isHelpSheetPreseted.toggle()
                return .none

            case .path(.element(id: _, action: .walletBirthday(.estimateHeightTapped))):
                state.path.append(.estimateBirthdaysDate(WalletBirthday.State.initial))
                return .none

            case .path(.element(id: _, action: .walletBirthday(.restoreTapped))):
                for element in state.path {
                    if case .walletBirthday(let walletBirthdayState) = element {
                        return .send(.resolveRestoreWithBirthday(walletBirthdayState.estimatedHeight))
                    }
                }
                return .none
                
            case .path(.element(id: _, action: .estimateBirthdaysDate(.helpSheetRequested))):
                state.isHelpSheetPreseted.toggle()
                return .none

            case .path(.element(id: _, action: .estimateBirthdaysDate(.estimateHeightReady))):
                for element in state.path {
                    if case .estimateBirthdaysDate(let estimateBirthdaysDateState) = element {
                        state.path.append(.estimatedBirthday(estimateBirthdaysDateState))
                    }
                }
                return .none
                
            case .path(.element(id: _, action: .estimatedBirthday(.restoreTapped))):
                for element in state.path {
                    if case .estimatedBirthday(let estimatedBirthdayState) = element {
                        return .send(.resolveRestoreWithBirthday(estimatedBirthdayState.estimatedHeight))
                    }
                }
                return .none

            default: return .none
            }
        }
    }
}
