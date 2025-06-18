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
        public var isSwapExperienceEnabled = true
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

        public var isValidForm: Bool {
            selectedAsset != nil
            && !address.isEmpty
            && amount > 0
            && !isInsufficientFunds
        }
        
        public var isInsufficientFunds: Bool {
            guard let selectedAsset else {
                return false
            }
            
            guard let zecAsset else {
                return false
            }

            let spendableZec = walletBalancesState.shieldedBalance.decimalValue.doubleValue
            
            switch (isSwapExperienceEnabled, isInputInUsd) {
            case (true, false):
                return amount > spendableZec
            case (true, true):
                return (amount / zecAsset.usdPrice) > spendableZec
            case (false, false):
                return ((amount * selectedAsset.usdPrice) / zecAsset.usdPrice) > spendableZec
            case (false, true):
                return (amount / zecAsset.usdPrice) > spendableZec
            }
        }

        public var isCustomSlippageFieldVisible: Bool {
            slippageInSheet >= 40.0
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
    }

    public enum Action: BindableAction {
        case assetSelectRequested
        case assetTapped(SwapAsset)
        case balances(Balances.Action)
        case binding(BindingAction<SwapAndPay.State>)
        case closeAssetsSheetTapped
        case closeSlippageSheetTapped
        case dismissRequired
        case enableSwapExperience(Bool)
        case eraseSearchTermTapped
        case getQuoteTapped
        case nextTapped
        case onAppear
        case scanTapped
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
                return .merge(
                    .send(.walletBalances(.onAppear)),
                    .run { send in
                        let swapAssets = try? await swapAndPay.swapAssets()
                        if let swapAssets {
                            await send(.swapAssetsLoaded(swapAssets))
                        }
                    }
                )

            case .binding(\.customSlippage):
                if !state.customSlippage.isEmpty {
                    if let input = state.slippageFormatter.number(from: state.customSlippage)?.doubleValue, input > 0.0 && input < 100.0 {
                        state.slippageInSheet = input * 10.0
                    }
                }
                return .none
                
            case .binding(\.searchTerm):
                return .send(.updateAssetsAccordingToSearchTerm)

            case .enableSwapExperience(let enable):
                state.isSwapExperienceEnabled = enable
                if !state.isInputInUsd {
                    if state.isSwapExperienceEnabled {
                        if let zecAsset = state.zecAsset, let selectedAsset = state.selectedAsset {
                            let amountInToken = (state.amount * selectedAsset.usdPrice) / zecAsset.usdPrice
                            if let value = state.conversionFormatter.string(from: NSNumber(value: amountInToken)) {
                                state.amountText = value
                            }
                        }
                    } else {
                        if let zecAsset = state.zecAsset, let selectedAsset = state.selectedAsset {
                            let amountInToken = (state.amount * zecAsset.usdPrice) / selectedAsset.usdPrice
                            if let value = state.conversionFormatter.string(from: NSNumber(value: amountInToken)) {
                                state.amountText = value
                            }
                        }
                    }
                }
                return .none
            
            case .scanTapped:
                return .none
                
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
                if state.isSwapExperienceEnabled {
                    if state.isInputInUsd {
                        if let zecAsset = state.zecAsset {
                            let amountInUsd = state.amount * zecAsset.usdPrice
                            if let value = state.conversionFormatter.string(from: NSNumber(value: amountInUsd)) {
                                state.amountText = value
                            }
                        }
                    } else {
                        if let zecAsset = state.zecAsset {
                            let amountInUsd = state.amount / zecAsset.usdPrice
                            if let value = state.conversionFormatter.string(from: NSNumber(value: amountInUsd)) {
                                state.amountText = value
                            }
                        }
                    }
                } else {
                    if state.isInputInUsd {
                        if let selectedAsset = state.selectedAsset {
                            let amountInUsd = state.amount * selectedAsset.usdPrice
                            if let value = state.conversionFormatter.string(from: NSNumber(value: amountInUsd)) {
                                state.amountText = value
                            }
                        }
                    } else {
                        if let selectedAsset = state.selectedAsset {
                            let amountInUsd = state.amount / selectedAsset.usdPrice
                            if let value = state.conversionFormatter.string(from: NSNumber(value: amountInUsd)) {
                                state.amountText = value
                            }
                        }
                    }
                }
                return .none
                
            case .assetSelectRequested:
                state.assetSelectBinding = true
                return .none
                
            case .slippageChipTapped(let index):
                state.selectedSlippageChip = index
                switch index {
                case 0: state.slippage = 5.0
                case 1: state.slippage = 10.0
                case 2: state.slippage = 20.0
                default: break
                }
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
                switch state.slippage {
                case 5.0: state.selectedSlippageChip = 0
                case 10.0: state.selectedSlippageChip = 1
                case 20.0: state.selectedSlippageChip = 2
                default:
                    state.selectedSlippageChip = 3
                    if let value = state.slippageFormatter.string(from: NSNumber(value: state.slippage / 10.0)) {
                        state.customSlippage = value
                    }
                }
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
//                    state.selectedAsset = swapAssets.first(where: { $0.token.lowercased() == "aurora" && $0.chain.lowercased() == "near" })
                }
                return .send(.updateAssetsAccordingToSearchTerm)

            case .walletBalances:
                return .none
            }
        }
    }
}

// MARK: - Conversion Logic

extension SwapAndPay.State {
    public var primaryLabelFrom: String {
        guard let zecAsset else {
            return conversionFormatter.string(from: NSNumber(value: 0.0)) ?? "0.00"
        }

        guard let selectedAsset else {
            return conversionFormatter.string(from: NSNumber(value: 0.0)) ?? "0.00"
        }

        switch (isSwapExperienceEnabled, isInputInUsd) {
        case (true, false):
            return amountText
        case (true, true):
            return amountText
        case (false, false):
            let amountInToken = (amount * selectedAsset.usdPrice) / zecAsset.usdPrice
            return conversionFormatter.string(from: NSNumber(value: amountInToken)) ?? "\(amountInToken)"
        case (false, true):
            return Decimal(amount).formatted(.currency(code: CurrencyISO4217.usd.code))
        }
    }
    
    public var secondaryLabelFrom: String {
        guard let zecAsset else {
            return conversionFormatter.string(from: NSNumber(value: 0.0)) ?? "0.00"
        }
        
        guard let selectedAsset else {
            return conversionFormatter.string(from: NSNumber(value: 0.0)) ?? "0.00"
        }

        switch (isSwapExperienceEnabled, isInputInUsd) {
        case (true, false):
            let amountInUsd = amount * zecAsset.usdPrice
            return Decimal(amountInUsd).formatted(.currency(code: CurrencyISO4217.usd.code))
        case (true, true):
            let amountInUsd = amount / zecAsset.usdPrice
            return conversionFormatter.string(from: NSNumber(value: amountInUsd)) ?? "\(amountInUsd)"
        case (false, false):
            let amountInUsd = amount * selectedAsset.usdPrice
            return Decimal(amountInUsd).formatted(.currency(code: CurrencyISO4217.usd.code))
        case (false, true):
            let amountInUsd = amount / zecAsset.usdPrice
            return conversionFormatter.string(from: NSNumber(value: amountInUsd)) ?? "\(amountInUsd)"
        }
    }
    
    public var primaryLabelTo: String {
        guard let zecAsset else {
            return formatter.string(from: NSNumber(value: 0.0)) ?? "0.00"
        }

        guard let selectedAsset else {
            return formatter.string(from: NSNumber(value: 0.0)) ?? "0.00"
        }

        switch (isSwapExperienceEnabled, isInputInUsd) {
        case (true, false):
            let amountInToken = (amount * zecAsset.usdPrice) / selectedAsset.usdPrice
            return conversionFormatter.string(from: NSNumber(value: amountInToken)) ?? "\(amountInToken)"
        case (true, true):
            return Decimal(amount).formatted(.currency(code: CurrencyISO4217.usd.code))
        case (false, false):
            return amountText
        case (false, true):
            return amountText
        }
    }
    
    public var secondaryLabelTo: String {
        guard let zecAsset else {
            return conversionFormatter.string(from: NSNumber(value: 0.0)) ?? "0.00"
        }

        guard let selectedAsset else {
            return conversionFormatter.string(from: NSNumber(value: 0.0)) ?? "0.00"
        }

        switch (isSwapExperienceEnabled, isInputInUsd) {
        case (true, false):
            let amountInUsd = amount * zecAsset.usdPrice
            return Decimal(amountInUsd).formatted(.currency(code: CurrencyISO4217.usd.code))
        case (true, true):
            let amountInToken = amount / selectedAsset.usdPrice
            return conversionFormatter.string(from: NSNumber(value: amountInToken)) ?? "\(amountInToken)"
        case (false, false):
            let amountInUsd = amount * selectedAsset.usdPrice
            return Decimal(amountInUsd).formatted(.currency(code: CurrencyISO4217.usd.code))
        case (false, true):
            let amountInToken = amount / selectedAsset.usdPrice
            return conversionFormatter.string(from: NSNumber(value: amountInToken)) ?? "\(amountInToken)"
        }
    }
    
    public var maxLabel: String {
        guard let zecAsset else {
            return conversionFormatter.string(from: NSNumber(value: 0.0)) ?? "0.00"
        }

        let amountInUsd = walletBalancesState.shieldedBalance.decimalValue.roundedZec.doubleValue * zecAsset.usdPrice

        switch (isSwapExperienceEnabled, isInputInUsd) {
        case (true, false):
            return spendableBalance
        case (true, true):
            return Decimal(amountInUsd).formatted(.currency(code: CurrencyISO4217.usd.code))
        case (false, false):
            return spendableBalance
        case (false, true):
            return Decimal(amountInUsd).formatted(.currency(code: CurrencyISO4217.usd.code))
        }
    }
}

// MARK: - String Representations

extension SwapAndPay.State {
    public var spendableBalance: String {
        formatter.string(from: walletBalancesState.shieldedBalance.decimalValue.roundedZec) ?? ""
    }
    
    public var slippageDiff: String {
        guard let selectedAsset else {
            return formatter.string(from: NSNumber(value: 0.0)) ?? "0.00"
        }
        
        let amountInUsd = amount * (isInputInUsd ? 1.0 : selectedAsset.usdPrice)
        let amountInUsdWithSlippage = amountInUsd + (slippageInSheet * 0.001 * amountInUsd)
        
        return Decimal(amountInUsdWithSlippage - amountInUsd).formatted(.currency(code: CurrencyISO4217.usd.code))
    }
    
    public var localePlaceholder: String {
        usdFormatter.string(from: NSNumber(value: 0.0)) ?? "0.00"
    }
    
    public var rateToOneZec: String? {
        guard let selectedAsset else {
            return nil
        }
        
        guard let zecAsset else {
            return nil
        }
        
        return formatter.string(from: NSNumber(value: zecAsset.usdPrice / selectedAsset.usdPrice))
    }
    
    public func slippageString(value: Double) -> String {
        let value = slippageFormatter.string(from: NSNumber(value: value)) ?? ""
        
        return "\(value)%"
    }
    
    public var currentSlippageString: String {
        slippageString(value: slippage / 10.0)
    }

    public var currentSlippageInSheetString: String {
        slippageString(value: slippageInSheet / 10.0)
    }

    public var slippage05String: String {
        slippageString(value: 0.5)
    }

    public var slippage1String: String {
        slippageString(value: 1.0)
    }

    public var slippage2String: String {
        slippageString(value: 2.0)
    }

    public var slippage0String: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale.current
        
        let value = formatter.string(from: NSNumber(value: 0)) ?? ""

        return "\(value)%"
    }
}

// MARK: - Formatters

extension SwapAndPay.State {
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

    public var conversionFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 8
        formatter.usesGroupingSeparator = false
        formatter.locale = Locale.current
        
        return formatter
    }

    public var slippageFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale.current
        
        return formatter
    }
}
