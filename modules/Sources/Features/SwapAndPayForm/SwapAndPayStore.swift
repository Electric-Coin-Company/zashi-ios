//
//  SwapAndPayStore.swift
//  modules
//
//  Created by Lukáš Korba on 23.05.2025.
//

import Foundation
import ComposableArchitecture

import BalanceBreakdown
import SDKSynchronizer
import WalletBalances
import SwapAndPay

@Reducer
public struct SwapAndPay {
    @ObservableState
    public struct State {
        public var address = ""
        public var assetSelectBinding = false
        public var balancesBinding = false
        public var balancesState = Balances.State.initial
        public var chain: String?
        public var isAddressBookHintVisible = false
        public var isNotAddressInAddressBook = false
        public var isPopToRootBack = false
        public var isQuotePresented = false
        public var isQuoteUnavailablePresented = false
        public var isSlippagePresented = false
        public var searchTerm = ""
        public var selectedAsset: SwapAsset?
        public var sheetHeight: CGFloat = 0.0
        public var slippage = 0.0
        public var swapAssets: IdentifiedArrayOf<SwapAsset> = []
        public var token: String?
        public var walletBalancesState: WalletBalances.State
    }
    
    public enum Action: BindableAction {
        case assetSelectRequested
        case balances(Balances.Action)
        case binding(BindingAction<SwapAndPay.State>)
        case closeAssetsSheetTapped
        case closeSlippageSheetTapped
        case dismissRequired
        case eraseSearchTermTapped
        case getQuoteTapped
        case nextTapped
        case onAppear
        case slippageTapped
        case swapAssetsLoaded(IdentifiedArrayOf<SwapAsset>)
        case walletBalances(WalletBalances.Action)
    }
    
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.swapAndPay) var swapAndPay

    public init() { }
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        
        Scope(state: \.balancesState, action: \.balances) {
            Balances()
        }

        Scope(state: \.walletBalancesState, action: \.walletBalances) {
            WalletBalances()
        }
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    let swapAssets = try? await swapAndPay.swapAssets()
                    if let swapAssets {
                        await send(.swapAssetsLoaded(swapAssets))
                    }
                }
                
            case .binding:
                return .none
                
            case .assetSelectRequested:
                state.assetSelectBinding = true
                return .none
                
            case .balances:
                return .none
                
            case .closeAssetsSheetTapped:
                state.assetSelectBinding = false
                return .none

            case .closeSlippageSheetTapped:
                state.isSlippagePresented = false
                return .none
                
            case .nextTapped:
                return .none
                
            case .eraseSearchTermTapped:
                return .none
                
            case .getQuoteTapped:
                //                state.isQuotePresented = true
                state.isQuoteUnavailablePresented = true
                return .none
                
            case .slippageTapped:
                state.isSlippagePresented = true
                return .none
                
            case .dismissRequired:
                return .none
                
            case .swapAssetsLoaded(let swapAssets):
                state.swapAssets = swapAssets
                return .none

            case .walletBalances:
                return .none
            }
        }
    }
}
