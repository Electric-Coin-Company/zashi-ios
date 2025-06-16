//
//  SwapAndPayStore.swift
//  modules
//
//  Created by Lukáš Korba on 23.05.2025.
//

import Foundation
import ComposableArchitecture

import Models
import BalanceBreakdown
import SDKSynchronizer
import WalletBalances
import SwapAndPay

@Reducer
public struct SwapAndPay {
    @ObservableState
    public struct State {
        public var address = ""
        public var amountText = ""
        public var assetSelectBinding = false
        public var balancesBinding = false
        public var balancesState = Balances.State.initial
        public var chain: String?
        public var customSlippage = ""
        public var isAddressBookHintVisible = false
        public var isInputInUsd = false
        public var isNotAddressInAddressBook = false
        public var isPopToRootBack = false
        public var isQuotePresented = false
        public var isQuoteUnavailablePresented = false
        public var isSlippagePresented = false
        public var searchTerm = ""
        public var selectedAsset: SwapAsset?
        public var sheetHeight: CGFloat = 0.0
        public var slippage = 10.0
        public var slippageInSheet = 10.0
        public var selectedSlippageChip = 1
        public var swapAssets: IdentifiedArrayOf<SwapAsset> = []
        public var swapAssetsToPresent: IdentifiedArrayOf<SwapAsset> = []
        public var token: String?
        public var walletBalancesState: WalletBalances.State
        public var zecAsset: SwapAsset?

        public var rateToOneZec: String? {
            guard let selectedAsset else {
                return nil
            }
            
            guard let zecAsset else {
                return nil
            }
            
            return String(format: "%0.8f%", zecAsset.usdPrice / selectedAsset.usdPrice)
        }
        
        public var isValidForm: Bool {
            selectedAsset != nil
        }
        
        public var isInsufficientFunds: Bool {
            guard let selectedAsset else {
                return false
            }
            
            guard let zecAsset else {
                return false
            }

            let spendableUsd = walletBalancesState.shieldedBalance.decimalValue.doubleValue * zecAsset.usdPrice
            
            let amountInUsd = amount * (isInputInUsd ? 1.0 : selectedAsset.usdPrice)
            let amountInUsdWithSlippage = amountInUsd + (slippage * 0.001 * amountInUsd)

            return amountInUsdWithSlippage > spendableUsd
        }

        public var usdFormatter: NumberFormatter {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
            formatter.locale = Locale.current
            
            return formatter
        }
        
        public var formatter: NumberFormatter {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 8
            formatter.locale = Locale.current
            
            return formatter
        }
        
        public var isCustomSlippageFieldVisible: Bool {
            slippageInSheet >= 40.0
        }
        
        public var localePlaceholder: String {
            usdFormatter.string(from: NSNumber(value: 0.0)) ?? "0.00"
        }
        
        public var spendableAmount: Double {
            guard let zecAsset else {
                return walletBalancesState.shieldedBalance.decimalValue.doubleValue
            }

            return walletBalancesState.shieldedBalance.decimalValue.doubleValue * zecAsset.usdPrice
        }
        
        public var amount: Double {
            if !_XCTIsTesting {
                @Dependency(\.numberFormatter) var numberFormatter

                return numberFormatter.number(amountText)?.doubleValue ?? 0.0
            } else {
                return 0.0
            }
        }
        
        public var spendableUSDBalance: String {
            Decimal(spendableAmount).formatted(.currency(code: CurrencyISO4217.usd.code))
        }

        public var recipientGetsConverted: String {
            guard let selectedAsset else {
                return formatter.string(from: NSNumber(value: 0.0)) ?? "0.00"
            }
            
            var amountWithRate = amount
            
            if isInputInUsd {
                amountWithRate /= selectedAsset.usdPrice
            } else {
                amountWithRate *= selectedAsset.usdPrice
            }
            
            let tokenString = formatter.string(from: NSNumber(value: amountWithRate)) ?? "\(amount) \(selectedAsset.token)"
            
            return isInputInUsd ?
            "\(tokenString) \(selectedAsset.token)"
            : Decimal(amountWithRate).formatted(.currency(code: CurrencyISO4217.usd.code))
        }
        
        public var youPayZec: String {
            guard let zecAsset else {
                return formatter.string(from: NSNumber(value: 0.0)) ?? "0.00"
            }

            guard let selectedAsset else {
                return formatter.string(from: NSNumber(value: 0.0)) ?? "0.00"
            }
            
            let amountInUsd = amount * (isInputInUsd ? 1.0 : selectedAsset.usdPrice)
            let amountInUsdWithSlippage = amountInUsd + (slippage * 0.001 * amountInUsd)
            let amountInZec = amountInUsdWithSlippage / zecAsset.usdPrice

            return formatter.string(from: NSNumber(value: amountInZec)) ?? "\(amountInZec)"
        }
        
        public var youPayZecConverted: String {
            guard let selectedAsset else {
                return formatter.string(from: NSNumber(value: 0.0)) ?? "0.00"
            }
            
            let amountInUsd = amount * (isInputInUsd ? 1.0 : selectedAsset.usdPrice)
            let amountInUsdWithSlippage = amountInUsd + (slippage * 0.001 * amountInUsd)
            
            return Decimal(amountInUsdWithSlippage).formatted(.currency(code: CurrencyISO4217.usd.code))
        }
        
        public var slippageDiff: String {
            guard let selectedAsset else {
                return formatter.string(from: NSNumber(value: 0.0)) ?? "0.00"
            }
            
            let amountInUsd = amount * (isInputInUsd ? 1.0 : selectedAsset.usdPrice)
            let amountInUsdWithSlippage = amountInUsd + (slippageInSheet * 0.001 * amountInUsd)
            
            return Decimal(amountInUsdWithSlippage - amountInUsd).formatted(.currency(code: CurrencyISO4217.usd.code))
        }
    }

    public enum Action: BindableAction {
        case assetSelectRequested
        case assetTapped(SwapAsset)
        case balances(Balances.Action)
        case binding(BindingAction<SwapAndPay.State>)
        case closeAssetsSheetTapped
        case closeSlippageSheetTapped
        case dismissRequired
        case eraseSearchTermTapped
        case getQuoteTapped
        case nextTapped
        case onAppear
        case slippageChipTapped(Int)
        case slippageSetConfirmTapped
        case slippageTapped
        case swapAssetsLoaded(IdentifiedArrayOf<SwapAsset>)
        case switchInputTapped
        case updateAssetsAccordingToSearchTerm
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

            case .binding(\.customSlippage):
                if !state.customSlippage.isEmpty {
                    if let input = state.formatter.number(from: state.customSlippage)?.doubleValue, input > 0.0 && input < 100.0 {
                        state.slippageInSheet = input * 10.0
                    }
                }
                return .none
                
            case .binding(\.searchTerm):
                return .send(.updateAssetsAccordingToSearchTerm)

            case .binding:
                return .none
                
            case .updateAssetsAccordingToSearchTerm:
                guard !state.searchTerm.isEmpty else {
                    state.swapAssetsToPresent = state.swapAssets
                    return .none
                }
                state.swapAssetsToPresent.removeAll()
                let tokenNameMatch = state.swapAssets.filter { $0.tokenName.localizedCaseInsensitiveContains(state.searchTerm) }
                let tokenMatch = state.swapAssets.filter { $0.token.localizedCaseInsensitiveContains(state.searchTerm) }
                let chainNameMatch = state.swapAssets.filter { $0.chainName.localizedCaseInsensitiveContains(state.searchTerm) }
                let chainMatch = state.swapAssets.filter { $0.chain.localizedCaseInsensitiveContains(state.searchTerm) }
                state.swapAssetsToPresent.append(contentsOf: tokenNameMatch)
                state.swapAssetsToPresent.append(contentsOf: tokenMatch)
                state.swapAssetsToPresent.append(contentsOf: chainNameMatch)
                state.swapAssetsToPresent.append(contentsOf: chainMatch)
                return .none

            case .assetTapped(let asset):
                state.selectedAsset = asset
                state.assetSelectBinding = false
                return .none

            case .switchInputTapped:
                state.isInputInUsd.toggle()
                return .none
                
            case .assetSelectRequested:
                state.assetSelectBinding = true
                return .none
                
            case .slippageChipTapped(let index):
                state.selectedSlippageChip = index
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
                state.searchTerm = ""
                return .send(.updateAssetsAccordingToSearchTerm)
                
            case .getQuoteTapped:
                return .run { send in
                    do {
                        try await swapAndPay.quote()
                    } catch {
                        print(error)
                    }
                }
                //                state.isQuotePresented = true
                //state.isQuoteUnavailablePresented = true
//                return .none
                
            case .slippageTapped:
                state.isSlippagePresented = true
                state.slippageInSheet = state.slippage
                return .none
                
            case .slippageSetConfirmTapped:
                state.isSlippagePresented = false
                state.slippage = state.slippageInSheet
                return .none
                
            case .dismissRequired:
                return .none
                
            case .swapAssetsLoaded(let swapAssets):
                state.swapAssets = swapAssets
                state.zecAsset = swapAssets.first(where: { $0.token.lowercased() == "zec" })
                if state.selectedAsset == nil {
                    state.selectedAsset = swapAssets.first(where: { $0.token.lowercased() == "usdc" && $0.chain.lowercased() == "near" })
                }
                return .send(.updateAssetsAccordingToSearchTerm)

            case .walletBalances:
                return .none
            }
        }
    }
}
