//
//  RestoreWalletCoordFlowStore.swift
//  Zashi
//
//  Created by Lukáš Korba on 27-03-2025.
//

import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit

import MnemonicSwift
import Pasteboard
import WalletStorage

// Path
import RestoreInfo
import WalletBirthday

@Reducer
public struct RestoreWalletCoordFlow {
    @Reducer
    public enum Path {
        case estimateBirthdaysDate(WalletBirthday)
        case estimatedBirthday(WalletBirthday)
        case restoreInfo(RestoreInfo)
        case walletBirthday(WalletBirthday)
    }
    
    @ObservableState
    public struct State {
        public var isHelpSheetPreseted = false
        public var isValidSeed = false
        public var nextIndex: Int?
        public var path = StackState<Path.State>()
        public var prevWords: [String] = Array(repeating: "", count: 24)
        public var selectedIndex: Int?
        public var suggestedWords: [String] = []
        public var words: [String] = Array(repeating: "", count: 24)
        public var wordsValidity: [Bool] = Array(repeating: true, count: 24)

        public init() { }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<RestoreWalletCoordFlow.State>)
        case evaluateSeedValidity
        case failedToRecover(ZcashError)
        case helpSheetRequested
        case nextTapped
        case path(StackActionOf<Path>)
        case resolveRestoreWithBirthday(BlockHeight)
        case selectedIndex(Int?)
        case successfullyRecovered
        case suggestedWordTapped(String)
        case suggestionsRequested(Int)
        #if DEBUG
        case debugPasteSeed
        #endif
    }

    @Dependency(\.mnemonic) var mnemonic
    @Dependency(\.pasteboard) var pasteboard
    @Dependency(\.walletStorage) var walletStorage

    public init() { }

    public var body: some Reducer<State, Action> {
        coordinatorReduce()

        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding(\.words):
                let changedIndices = state.words.indices.filter { state.words[$0] != state.prevWords[$0] }
                state.prevWords = state.words

                if let index = changedIndices.first {
                    let word = state.words[index]
                    if word.hasSuffix(" ") {
                        state.words[index] = word.trimmingCharacters(in: .whitespaces)
                        state.prevWords = state.words
                        return .send(.suggestedWordTapped(state.words[index]))
                    }
                    
                    return .send(.suggestionsRequested(index))
                }
                
                return .none
                
            case .selectedIndex(let index):
                state.selectedIndex = index
                if let index {
                    return .send(.suggestionsRequested(index))
                }
                return .none
                
            case .suggestionsRequested(let index):
                let prefix = state.words[index]
                if prefix.isEmpty {
                    state.suggestedWords = []
                } else {
                    state.suggestedWords = mnemonic.suggestWords(prefix)
                    state.wordsValidity[index] = !state.suggestedWords.isEmpty
                }
                return .send(.evaluateSeedValidity)

            case .suggestedWordTapped(let word):
                if let index = state.selectedIndex {
                    state.words[index] = word
                    state.prevWords = state.words
                    state.nextIndex = index + 1 < 24 ? index + 1 : 0
                    return .send(.evaluateSeedValidity)
                }
                return .none
                
            case .helpSheetRequested:
                state.isHelpSheetPreseted.toggle()
                return .none

            case .evaluateSeedValidity:
                do {
                    try mnemonic.isValid(state.words.joined(separator: " "))
                    state.isValidSeed = true
                } catch {
                    state.isValidSeed = false
                }
                return .none
                
                #if DEBUG
            case .debugPasteSeed:
                do {
                    let seedToPaste = pasteboard.getString()?.data ?? ""
                    try mnemonic.isValid(seedToPaste)
                    state.words = seedToPaste.components(separatedBy: " ")
                    state.isValidSeed = true
                } catch {
                    state.isValidSeed = false
                }
                return .none
                #endif

            default: return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
