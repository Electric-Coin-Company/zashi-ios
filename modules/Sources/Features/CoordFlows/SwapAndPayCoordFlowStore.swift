//
//  SwapAndPayCoordFlowStore.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-05-14.
//

import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit

import AudioServices
import Models
//import Utils
import MnemonicClient
import SDKSynchronizer
import WalletStorage
import ZcashSDKEnvironment
//import UIComponents
//import Models
//import Generated
//import BalanceFormatter
//import WalletBalances
//import LocalAuthenticationHandler
import AddressBookClient
//import MessageUI
//import SupportDataGenerator
//import KeystoneHandler
//import TransactionDetails
import AddressBook
import UserMetadataProvider

// Path
import AddressBook
import Scan
import SendConfirmation
import SwapAndPayForm
import TransactionDetails

@Reducer
public struct SwapAndPayCoordFlow {
    @Reducer
    public enum Path {
        case addressBook(AddressBook)
        case addressBookContact(AddressBook)
        case confirmWithKeystone(SendConfirmation)
        case preSendingFailure(SendConfirmation)
        case scan(Scan)
        case sending(SendConfirmation)
        case sendResultFailure(SendConfirmation)
        case sendResultResubmission(SendConfirmation)
        case sendResultSuccess(SendConfirmation)
        case swapAndPayForm(SwapAndPay)
        case swapAndPayOptInForced(SwapAndPay)
        case transactionDetails(TransactionDetails)
    }
    
    @ObservableState
    public struct State {
        public enum Result: Equatable {
            case failure
            case resubmission
            case success
        }
        
        public var failedCode: Int?
        public var failedDescription = ""
        public var failedPcztMsg: String?
        public var isHelpSheetPresented = false
        public var isOptInFlow = false
        public var path = StackState<Path.State>()
        public var sendingScreenOnAppearTimestamp: TimeInterval = 0
        @Shared(.inMemory(.selectedWalletAccount)) public var selectedWalletAccount: WalletAccount? = nil
        public var selectedOperationChip = 0
        public var swapAndPayState = SwapAndPay.State.initial
        @Shared(.inMemory(.swapAPIAccess)) var swapAPIAccess: WalletStorage.SwapAPIAccess? = nil
        @Shared(.inMemory(.transactions)) public var transactions: IdentifiedArrayOf<TransactionState> = []
        public var txIdToExpand: String?
        
        public var isSwapInFlight: Bool {
            swapAndPayState.isQuoteRequestInFlight
        }
        
        public init() { }
    }

    public enum Action: BindableAction {
        case backButtonTapped
        case binding(BindingAction<SwapAndPayCoordFlow.State>)
        case customBackRequired
        case helpSheetRequested
        case onAppear
        case operationChipTapped(Int)
        case path(StackActionOf<Path>)
        case sendDone
        case sendFailed(ZcashError?, Bool)
        case stopSending
        case swapAndPay(SwapAndPay.Action)
        case swapRequested
        case updateFailedData(Int?, String, String?)
        case updateResult(State.Result?)
        case updateTxIdToExpand(String?)
    }

    @Dependency(\.audioServices) var audioServices
//    @Dependency(\.addressBook) var addressBook
//    @Dependency(\.audioServices) var audioServices
    @Dependency(\.localAuthentication) var localAuthentication
    @Dependency(\.derivationTool) var derivationTool
//    @Dependency(\.keystoneHandler) var keystoneHandler
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.mnemonic) var mnemonic
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.userMetadataProvider) var userMetadataProvider
    @Dependency(\.walletStorage) var walletStorage
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment
    @Dependency(\.swapAndPay) var swapAndPay

    public init() { }

    public var body: some Reducer<State, Action> {
        coordinatorReduce()

        BindingReducer()
        
        Scope(state: \.swapAndPayState, action: \.swapAndPay) {
            SwapAndPay()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                // Here must be the determination if the start is to the opt-in screens or direct to the form
                //let swapAPIAccess = WalletStorage.SwapAPIAccess.notResolved
                let swapAPIAccess = walletStorage.exportSwapAPIAccess()
                state.$swapAPIAccess.withLock { $0 = swapAPIAccess }
                state.isOptInFlow = swapAPIAccess == .notResolved
                state.swapAndPayState.isOptInFlow = state.isOptInFlow
                return .none
                
            case .operationChipTapped(let index):
                state.selectedOperationChip = index
                return .send(.swapAndPay(.enableSwapExperience(index == 0)))
                
            case .helpSheetRequested:
                state.isHelpSheetPresented.toggle()
                return .none

            case .path(.element(id: _, action: .swapAndPayForm(.helpSheetRequested(let index)))):
                state.selectedOperationChip = index
                state.isHelpSheetPresented.toggle()
                return .none

            case .updateTxIdToExpand(let txId):
                state.txIdToExpand = txId
                return .none
                
            default: return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
