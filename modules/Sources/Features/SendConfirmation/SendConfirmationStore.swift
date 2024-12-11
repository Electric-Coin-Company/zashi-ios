//
//  SendConfirmationStore.swift
//  
//
//  Created by Lukáš Korba on 13.05.2024.
//

import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit
import AudioServices
import Utils
import Scan
import PartialProposalError
import MnemonicClient
import SDKSynchronizer
import WalletStorage
import ZcashSDKEnvironment
import UIComponents
import Models
import Generated
import BalanceFormatter
import WalletBalances
import LocalAuthenticationHandler
import AddressBookClient
import MessageUI
import SupportDataGenerator

@Reducer
public struct SendConfirmation {
    @ObservableState
    public struct State: Equatable {
        public enum Destination: Equatable {
            case sending
        }
        
        public enum Result: Equatable {
            case failure
            case partial
            case resubmission
            case success
        }

        public enum StackDestination: Int, Equatable {
            case signWithKeystone = 0
            case scan
            case sending
        }

        public var address: String
        @Shared(.inMemory(.addressBookContacts)) public var addressBookContacts: AddressBookContacts = .empty
        public var alias: String?
        @Presents public var alert: AlertState<Action>?
        public var amount: Zatoshi
        public var canSendMail = false
        public var currencyAmount: RedactableString
        public var destination: Destination?
        public var failedCode: Int?
        public var failedDescription: String?
        @Shared(.inMemory(.featureFlags)) public var featureFlags: FeatureFlags = .initial
        public var feeRequired: Zatoshi
        public var isAddressExpanded = false
        public var isSending = false
        public var isTransparentAddress = false
        public var message: String
        public var messageToBeShared: String?
        public var partialProposalErrorState: PartialProposalError.State
        public var partialProposalErrorViewBinding = false
        public var pczt: Data?
        public var proposal: Proposal?
        public var randomSuccessIconIndex = 0
        public var randomFailureIconIndex = 0
        public var randomResubmissionIconIndex = 0
        public var result: Result?
        public var scanState: Scan.State = .initial
        @Shared(.inMemory(.selectedWalletAccount)) public var selectedWalletAccount: WalletAccount? = nil
        public var stackDestination: StackDestination?
        public var stackDestinationBindingsAlive = 0
        public var supportData: SupportData?
        public var txIdToExpand: String?
        @Shared(.inMemory(.walletAccounts)) public var walletAccounts: [WalletAccount] = []
        @Shared(.inMemory(.zashiWalletAccount)) public var zashiWalletAccount: WalletAccount? = nil

        // TODO: fix or remove it
        public var tmpHelper = false
        
        public var addressToShow: String {
            isTransparentAddress
            ? address
            : isAddressExpanded
            ? address
            : address.zip316
        }
        
        public var successIlustration: Image {
            switch randomSuccessIconIndex {
            case 1: return Asset.Assets.Illustrations.success1.image
            default: return Asset.Assets.Illustrations.success2.image
            }
            
        }

        public var failureIlustration: Image {
            switch randomFailureIconIndex {
            case 1: return Asset.Assets.Illustrations.failure1.image
            case 2: return Asset.Assets.Illustrations.failure2.image
            default: return Asset.Assets.Illustrations.failure3.image
            }
        }

        public var resubmissionIlustration: Image {
            switch randomResubmissionIconIndex {
            case 1: return Asset.Assets.Illustrations.resubmission1.image
            default: return Asset.Assets.Illustrations.resubmission2.image
            }
        }

        public init(
            address: String,
            amount: Zatoshi,
            currencyAmount: RedactableString = .empty,
            feeRequired: Zatoshi,
            isSending: Bool = false,
            message: String,
            partialProposalErrorState: PartialProposalError.State,
            partialProposalErrorViewBinding: Bool = false,
            proposal: Proposal?
        ) {
            self.address = address
            self.amount = amount
            self.currencyAmount = currencyAmount
            self.feeRequired = feeRequired
            self.isSending = isSending
            self.message = message
            self.partialProposalErrorState = partialProposalErrorState
            self.partialProposalErrorViewBinding = partialProposalErrorViewBinding
            self.proposal = proposal
        }
    }
    
    public enum Action: BindableAction, Equatable {
        case alert(PresentationAction<Action>)
        case backFromFailurePressed
        case binding(BindingAction<SendConfirmation.State>)
        case closeTapped
        case confirmWithKeystoneTapped
        case fetchedABContacts(AddressBookContacts)
        case getSignatureTapped
        case goBackPressed
        case goBackPressedFromRequestZec
        case onAppear
        case partialProposalError(PartialProposalError.Action)
        case partialProposalErrorDismiss
        case pcztResolved(Data)
        case rejectTapped
        case reportTapped
        case resolvePCZT
        case saveAddressTapped(RedactableString)
        case scan(Scan.Action)
        case sendDone
        case sendFailed(ZcashError?, Bool)
        case sendPartial([String], [String])
        case sendPressed
        case sendSupportMailFinished
        case sendTriggered
        case shareFinished
        case showHideButtonTapped
        case updateDestination(State.Destination?)
        case updateFailedData(Int, String)
        case updateResult(State.Result?)
        case updateStackDestination(SendConfirmation.State.StackDestination?)
        case updateTxIdToExpand(String?)
        case viewTransactionTapped
    }

    @Dependency(\.addressBook) var addressBook
    @Dependency(\.audioServices) var audioServices
    @Dependency(\.localAuthentication) var localAuthentication
    @Dependency(\.derivationTool) var derivationTool
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.mnemonic) var mnemonic
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.walletStorage) var walletStorage
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    public init() { }

    public var body: some Reducer<State, Action> {
        BindingReducer()
        
        Scope(state: \.partialProposalErrorState, action: \.partialProposalError) {
            PartialProposalError()
        }

        Scope(state: \.scanState, action: \.scan) {
            Scan()
        }
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.scanState.checkers = [.keystoneScanChecker]
                state.scanState.instructions = "Scan your Keystone wallet to connect"
                state.scanState.forceLibraryToHide = true
                state.randomSuccessIconIndex = Int.random(in: 1...2)
                state.randomFailureIconIndex = Int.random(in: 1...3)
                state.randomResubmissionIconIndex = Int.random(in: 1...2)
                state.isTransparentAddress = derivationTool.isTransparentAddress(state.address, zcashSDKEnvironment.network.networkType)
                state.canSendMail = MFMailComposeViewController.canSendMail()
                state.alias = nil
                if let account = state.zashiWalletAccount {
                    do {
                        let result = try addressBook.allLocalContacts(account.account)
                        let abContacts = result.contacts
                        if result.remoteStoreResult == .failure {
                            // TODO: [#1408] error handling https://github.com/Electric-Coin-Company/zashi-ios/issues/1408
                        }
                        return .send(.fetchedABContacts(abContacts))
                    } catch {
                        // TODO: [#1408] error handling https://github.com/Electric-Coin-Company/zashi-ios/issues/1408
                        return .none
                    }
                }
                return .none

            case .fetchedABContacts(let abContacts):
                state.addressBookContacts = abContacts
                state.alias = nil
                for contact in state.addressBookContacts.contacts {
                    if contact.id == state.address {
                        state.alias = contact.name
                        break
                    }
                }
                return .none
                
            case .alert(.presented(let action)):
                return .send(action)

            case .alert(.dismiss):
                state.alert = nil
                return .none

            case .binding:
                return .none

            case .saveAddressTapped:
                return .none

            case .showHideButtonTapped:
                state.isAddressExpanded.toggle()
                return .none

            case .goBackPressedFromRequestZec:
                return .none

            case .goBackPressed:
                return .none

            case .closeTapped, .viewTransactionTapped, .backFromFailurePressed:
                return .concatenate(
                    .send(.updateDestination(nil)),
                    .send(.updateResult(nil))
                )

            case .sendPressed:
                if state.featureFlags.sendingScreen {
                    state.isSending = true
                    return .concatenate(
                        .send(.updateDestination(.sending)),
                        .send(.sendTriggered)
                    )
                } else {
                    return .send(.sendTriggered)
                }
                
            case .sendTriggered:
                guard let proposal = state.proposal else {
                    return .send(.sendFailed("missing proposal".toZcashError(), true))
                }
                guard let zip32AccountIndex = state.selectedWalletAccount?.zip32AccountIndex else {
                    return .none
                }
                return .run { send in
                    if await !localAuthentication.authenticate() {
                        await send(.sendFailed(nil, true))
                        return
                    }

                    do {
                        let storedWallet = try walletStorage.exportWallet()
                        let seedBytes = try mnemonic.toSeed(storedWallet.seedPhrase.value())
                        let network = zcashSDKEnvironment.network.networkType
                        let spendingKey = try derivationTool.deriveSpendingKey(seedBytes, zip32AccountIndex, network)

                        let result = try await sdkSynchronizer.createProposedTransactions(proposal, spendingKey)
                        
                        switch result {
                        case .grpcFailure(let txIds):
                            await send(.updateTxIdToExpand(txIds.last))
                            await send(.sendFailed("sdkSynchronizer.createProposedTransactions".toZcashError(), false))
                        case let .failure(txIds, code, description):
                            await send(.updateFailedData(code, description))
                            await send(.updateTxIdToExpand(txIds.last))
                            await send(.sendFailed("sdkSynchronizer.createProposedTransactions".toZcashError(), true))
                        case let .partial(txIds: txIds, statuses: statuses):
                            await send(.updateTxIdToExpand(txIds.last))
                            await send(.sendPartial(txIds, statuses))
                        case .success(let txIds):
                            await send(.updateTxIdToExpand(txIds.last))
                            await send(.sendDone)
                        }
                    } catch {
                        await send(.sendFailed(error.toZcashError(), true))
                    }
                }

            case .sendDone:
                state.isSending = false
                if state.featureFlags.sendingScreen {
                    return .send(.updateResult(.success))
                } else {
                    return .none
                }

            case let .sendFailed(error, isFatal):
                state.isSending = false
                if state.featureFlags.sendingScreen {
                    return .send(.updateResult(isFatal ? .failure : .resubmission))
                } else {
                    if let error {
                        state.alert = AlertState.sendFailure(error)
                    }
                    return .none
                }
                
            case let .sendPartial(txIds, statuses):
                state.isSending = false
                state.partialProposalErrorViewBinding = true
                state.partialProposalErrorState.txIds = txIds
                state.partialProposalErrorState.statuses = statuses
                return .none

            case .updateTxIdToExpand(let txId):
                state.txIdToExpand = txId
                return .none
            
            case .partialProposalError:
                return .none
                
            case .partialProposalErrorDismiss:
                state.partialProposalErrorViewBinding = false
                return .none
                
            case .updateDestination(let destination):
                state.destination = destination
                return .none

            case .updateResult(let result):
                state.result = result
                if let result {
                    if result == .success {
                        audioServices.systemSoundVibrate()
                        return .none
                    } else {
                        return .run { _ in
                            audioServices.systemSoundVibrate()
                            try? await mainQueue.sleep(for: .seconds(1.0))
                            audioServices.systemSoundVibrate()
                        }
                    }
                } else {
                    return .none
                }
                
            case let .updateFailedData(code, desc):
                state.failedCode = code
                state.failedDescription = desc
                return .none
                
            case .updateStackDestination(let destination):
                if let destination {
                    state.stackDestinationBindingsAlive = destination.rawValue
                }
                state.stackDestination = destination
                return .none
                
            case .reportTapped:
                var supportData = SupportDataGenerator.generate()
                if let code = state.failedCode, let desc = state.failedDescription {
                    supportData.message =
                    """
                    \(code)
                    
                    \(desc)

                    \(supportData.message)
                    """
                }
                if state.canSendMail {
                    state.supportData = supportData
                } else {
                    state.messageToBeShared = supportData.message
                }
                return .none
                
            case .sendSupportMailFinished:
                state.supportData = nil
                return .none
                
            case .shareFinished:
                state.messageToBeShared = nil
                return .none
            
                // MARK: - Keystone
                
            case .getSignatureTapped:
                return .send(.updateStackDestination(.scan))
                
            case .rejectTapped:
                return .none
                
            case .confirmWithKeystoneTapped:
                return .concatenate(
                    .send(.resolvePCZT),
                    .send(.updateStackDestination(.signWithKeystone))
                    )
                
            case .scan(.cancelPressed):
                return .send(.updateStackDestination(.signWithKeystone))

            case .scan(.foundZA):
                if !state.tmpHelper {
                    state.tmpHelper = true
                    return .send(.updateStackDestination(.sending))
                }
                return .none
                
            case .scan:
                return .none
                
            case .resolvePCZT:
                guard let proposal = state.proposal, let account = state.selectedWalletAccount else {
                    return .none
                }
                return .run { send in
                    do {
                        let pczt = try await sdkSynchronizer.createPCZTFromProposal(account.id, proposal)
                        await send(.pcztResolved(pczt))
                    } catch {
                        print(error)
                    }
                }
                
            case .pcztResolved(let pczt):
//                if pcztMock.hexEncodedString() == pcztMock.hexadecimal2.hexEncodedString() {
//                    print("jasne")
//                } else {
//                    print("spatne")
//                }

                //print(pczt.hexEncodedString())
                
                //state.pczt = Data(pczt.map { String(format: "%02hhx", $0) }.joined().utf8)
                //state.pczt = Data(pczt.map { String(format: "%02x", $0) }.joined().utf8)
                //state.pczt = pczt
                //state.pczt = pczt.hexEncodedString().hexadecimal.hexEncodedString().hexadecimal
                state.pczt = pcztMock
//                state.pczt = pczt
//                state.pczt = pczt.hexEncodedData().hexEncodedString().hexadecimal
                return .none
            }
        }
    }
}

// MARK: Alerts

extension AlertState where Action == SendConfirmation.Action {
    public static func sendFailure(_ error: ZcashError) -> AlertState {
        AlertState {
            TextState(L10n.Send.Alert.Failure.title)
        } message: {
            TextState(L10n.Send.Alert.Failure.message(error.detailedMessage))
        }
    }
}

//extension Data {
//    func hexEncodedData() -> Data {
//        return map { String(format: "%02hhx", $0) }
//            .joined()
//            .data(using: .utf8) ?? Data()
//    }
//}

//extension String {
//    var hexadecimal: Data {
//        var data = Data(capacity: count / 2)
//
//        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
//        regex.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
//            let byteString = (self as NSString).substring(with: match!.range)
//            let num = UInt8(byteString, radix: 16)!
//            data.append(num)
//        }
//        guard data.count > 0 else { return Data() }
//        return data
//    }
//}
//
//extension Data {
//    func hexEncodedString() -> String {
//        return map { String(format: "%02hhx", $0) }.joined()
//    }
//}


//extension Data {
//    var hexadecimal2: Data {
//        // Convert each byte into a two-character hexadecimal string
//        let hexString = self.map { String(format: "%02hhx", $0) }.joined()
//        
//        // Convert the hex string back into a Data object
//        var result = Data(capacity: hexString.count / 2)
//        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
//        regex.enumerateMatches(in: hexString, range: NSRange(hexString.startIndex..., in: hexString)) { match, _, _ in
//            let byteString = (hexString as NSString).substring(with: match!.range)
//            let num = UInt8(byteString, radix: 16)!
//            result.append(num)
//        }
//        
//        return result
//    }
//}
//
extension String {
    var hexadecimal: Data {
        var data = Data(capacity: count / 2)

        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
            let byteString = (self as NSString).substring(with: match!.range)
            let num = UInt8(byteString, radix: 16)!
            data.append(num)
        }
        guard data.count > 0 else { return Data() }
        return data
    }
}
//
//extension Data {
//    func hexEncodedString() -> String {
//        return map { String(format: "%02hhx", $0) }.joined()
//    }
//}

let pcztMock = "50435a5401000000058ace9cb502d5a09cc70c0100e4d0a70185010001227a636173685f636c69656e745f6261636b656e643a70726f706f73616c5f696e666f14d4f10067c28046079b172dcbbf29e8c1bcd0a7010000000000fbc2f4300c01f0b7820d00e3347c8da4ee614674376cbc45359daa54f9b5493e01000000000000000000000000000000000000000000000000000000000000000002e6562a83f1d118b1ebec59479916c5b8d3fa6d78dd4ca614dc7da81bb7e07a867532eebf89f4fb5fca6c5c9b04364d25eb55b634963aaf2393603e3943746c001bc243bacfcaadb84e8f68e6fd7debe2afe29e73f6dfbd113fb399682fc9d31201294497fd6ccfcee689fe80f7f091da7e3601dff6bf8bf2115d88d525259042b32ac76a279e240849cc01feb52663930510eb3d82cb30748dfd8fcd6f5e77d73001c14755040c96fb9ef527d221a3024f9591fa05982a5d3a737dd6da1da119a8c10ceb3b115dfacb7d8c552c010001dddfc6512b314b5cea471515fe2e0f31e330b01d073dd86f3426315569d86f3a01f1c02f72610d5ced7305102c69aff6c3716474a9003af17ad2395e48e347ba4501e13fae7e7aea0e144e08f4a6809ff4eeacfd314f8a6cd03b1c7426c812d4ec34cd39ca4be3c11e42a77c7a2ea889b66cf6269189d14d319aae08fbc4cc46dd0d81f0df8720f6fa32f7658c1ce5302757c1315ab02f9f1a2ffde66cd3964fa43301b1cf97f90901791948f776a526cdce603137eda0d17be6a1c58555f1aaddcb86b065c3b8380ff9f179be452f2910d33530c9eb02a14529649df362e4d7657f8047aed2031cb0d1619eb2328fe55d547b6d5844aed5af24c344fe12418f016066d85dda8d23b7089c973749f76cac1eb2ddc957151ae9733eda21ab33ca50ecbf08923a34270f39fcfe67469705f4f77f36cde0a31ae86dd9dd3b415f19d822c5e99fe728053fa0d4a57570daa295c0929b45d09311a830971ba8d9ae6ecf5b33987a267538a6c91f0faa200ad0bfbf8b43bf99a2d97310afe55d01c03952ee19ff1304f6353a2431e07d65e8c886ac2883c35494b8dc152a5894ae5ef75da8f7a03f33090bca87cff2362c9c8ee2606baa419f7ee278cf6183bb0fdc861d29b8784225ee0e27ddea4bee73dc6eaed214ad439ab8b630eeebf0725dc896fb7b59c99d6d7c047002f8f8a07d886b0bb3fce5b9e8b719489fed3d678ffa978a13c7a5a7b76f19f553286ae2265e1ddd77df9564194ee2aee9c11840eb23f5c65d7d54ff6a2c36eb86e2f08b878d944552e1f048fd852bf65c6c2b11bab35a4df5cca597a62313571bf65733bebbad7efbac9dbf7376f3962fde3f1ea3e8a9c6102e3db6bb6a0dc331d9f057d2373e616beb2471b9b6782f48f753eda31df96c8b598fbd76b93db93a53366a1ce80de405bcd305bc53b0a7bc365be9eac462ce126271bc3af815bca251c34b2fb16d8c212aa88a134060a717a5c3c888968571bdae7cef4a522dff6f2b23daf8c5094953cf740d5bb33a161290ce23567e11902abaa693a6503684ba67296ea5097df1d44ae69241ea94cba70ad33ed3c18e04c579befc060910ef1327eac24e9d0a0cc6fa2bf7f79df1d36aea6f49117f339c8e6a724518d111e8626429e857a61ab80b7c82edd324e367fdc81c5dd9c6effb2ae467389c14139e1af5d5c941f375efc08d03fe2ada7b79addeebf60ed0a6ab9eeb2f41986b0696f828ca0e70f25b72f8433843bae14a8ac6e5edefa21bfc74e861c3495fd106bd872e13a680b146c42f4ebc7732a8da294bcc403a9c0ba45aee46f3e028843814c042a5a7cb55a41d949cf23d27e7a9208c44b0dc77d9d47c3e4db210654c07be521231de93cc115d83ba276c885b3c1aba6129c73c6a36eb5bafe5a3fefc3b629f0f8cd5a2e3bcadf03d1bb86126cf2d4e601a843ef962de6d259b26961238277e20e8f38307a0cc4f89ef1c697a133f1f31184b7215806d772c92e4a3fa2a31365e0eb9af3af4797a47d2521b4d112f8efa47ac933f7ebc24f4921290b012b6ae51289a9b11165c8ff86633f87615a79f8254887fc1a8b9fc0c0008e52d3f003fb952b3f058960ebac617ebd6a1a00bb948cff43a40384c94c1bcc310b10cfb4002df9f0d30c45672946c316904181ba857172f86597f453d6ec2b9832e19012e366d790ff7141e475546286b05b23031cf956df8b01826034211774740c71b018e048fff5dc45cab533adc61fdafdc6f27c199b96f7fd08060997e583a5a639e03a0808080088581808008808080800800004a432d7c22f00c538ffb1e00016f231b0a339804b0d961461588fb887a20713a2832c3192f04e1c1f9f6c62af673a574187442c3ffaa052bd9baa126311bb322c4041f1e2cac9bbc58ab3822114deac67d70643f96957bbe061567abd33c68ab453111206671b830008ef48a889cb97bf74fb31b313b9b178a068ce08430397bbda0d64d3106cf0ef63885c747c1f9cbc1fa962ffc6990ac5b814179dac1dd8447464f11dc841dd50ba8c95038b80d7a0db0ef641f1088f3f10b09fb8bfdeab66c6619af452bde8c1522d9dee3922931043b2a101a6d79a7bba41b73347f7eb469a6059c7705f938e89f91a02910fd4bc22408d205346e54fb0ad7c12f8c73ad55a2e0d209752e623f1ce5e9a6b67ddee4a5b356c659e913ad9350ca4f60d85cf83d908eabda3056558df0b026cc8eb3f088dfb09f28bf662e7f4686a0302febddbaa74ff6b2a714fe36609150c6d770a75a854604266d38b00372e2a40ad9c31d5faa4fbe71d2f84dc795e4e47f34529d98c369b34417cf39538a90ecec2c3ff342b44e4cb2c5d3b7dcb29fc29f2bfb754ad17b04aeaafac2a2889ac370dbfc4e8fe7902704019d727dbf4bb78bd0702a2d804b23cb0a4bb49ffe3a58d990765985b016697cf3f550b18cc6868324b9f97c33c263e9b18deedbbf1a07b9f738efb10e2735d0725b70c9c7500b7e75774adb6ad5dcbbf0e8d8d678c4bf3f017334188c228e3a0c268353e86beed8ff62bf56d2c229a28b66d4d88dd165854f9cd18411bc2fbfaaccf1836af9d73e77968ea988a072843bda6f989f7bdb3a921a8a2445f24cfdcb0d32bd5138463e63cb7aa6e198855ca8ec0d83537c5b321d7192e605167fc0ac7181a797a966765a3c491a61180bbe21f7bf598ee957491aceb2ca66335f895038007e3602d6c8a586b8e0d0bdadca72aa0673597999beaa89815d237c1e34ad5edc96c71bf4b10fe4995ed97c2f475345d1dee78fda8a63bf87ddbc7408d51547e02d5c9c613c6c048d43a2aac2298a016c260344c3fb60a31ac6ab541060069e25c9bdf9ebcbeca3e3d82744acdc529529940a519711d093eddc9701a08d06015276cbfd50c6e793c4659e824954f9338b0542826af3f7947af1852cb0b5a219000001207a636173685f636c69656e745f6261636b656e643a6f75747075745f696e666fd80100d5017531767a7335796134633771787537656a7732393438346b616372736b7974766b6b37366c736333336c6b6c78777679787771746d346572796e7678326c7175776e75787a79326c3774747a3838366a366133617037776a3963647a79647a6b71387339356d766c6333786477633477386175377374723667793932686464657872716a686d6b7933337666346b7430646e6e33396737736a6d79326b7a7835667861397a613836326d666e356136666739686d6330706a757374746e366b757a736164767865396e75323568303570746564676d01f58b2ce49df6f6074947f961d3af0475ab29c3fd2c67871a2f1e2a6768004b1e9392be61b28d4dbb0f90a3d56e9694d4a7dfca56d1dcdf481d3f4a387a031f27a95f5d0451d336c61cb989b45f2849034b0612f6e31d7f80efa76078251964105e33b64def45aa380ff8940ff8aa02f7f55b8311432fd0da299c1d50cb5b86a80001c50d8395fa39bae984c3febb833b6cbf6a633128e0555d11c3657d786521719b10be1d9617693122085a0601c0843d0104c492aec13dd15cc78519d735e879a7183b9b2ff9ec1d249811cf8726d5771e01bce9e9bb2805f59c31840490319aec3a64d41ab7512e8fa6b7148743aed7283201a2c4b623f4ed315fe7814266de5500351d9533aaef5d889fdf333045b3e9ff3f886084c64f857fb7b16d02e4f20a85ae2d3cd2f2552ec267b3535b006517180a345762f3ab50409df7e3da4e60c3b46f7bb3334af1beb93951759c4a0453630d01dcc3ac1768e7fee0e069c835d803c23322491ab69a867c1770c714d0401b7b997aa337016ba4ce2c72a94a786c1b23c927c57c1a5d8b2433c838c5295377fbbde828c62a07751f5fdd6d43a688874d6a7898f18df0aa2ecf401245a5616d82872215ee22df9a5e6bbcce9a3bdb822ed5a771da17381b72606fa00f6122437e6c4fbecf217276f14d3e1af7f01c0ed8efe67dd78e428cd05cdd04aee7112d24d6f6088116b340e7dbb02aaece5edae330ce2e68131a9f9ec897911597e831402135bcc72e93a795230628ec597b2ccdacaf864301c01101ef7f2ec5916baacb8977a8220f4482bf732560109f4fc0ae83336c2abbd7f491f23bd2406311b437276055202f73e7f6ae96da68e6a25e3cede407bcf1195afc69ccffac22ccf024965da59622c15db2cc7b9a37491e6f6b75f3135a692f66ace8d2344c58889c55ab5b7f362aa3c02568acebf5ca1ec30d6a7d7cd217a47d6a1b8311bf9462a5f939c6b743073ef9b30bae6122da1605bad6ec5d49b41d4d40caa96c1cf6302b66c5d2d10d3922ae2800cb93abe63b70c172de70362d9830e53800398884a7a64ff68ed99e0b9d2e26bdef115ced7bd36305a54386996133c4e65759f3731637a40eba67da103f98adbe364f148b0cc2042cafc6be1166fae39090ab4b354bfb6217b964453b63f8dbd10df936f1734973e0b3bd25f4ed440566c923085903f696bc6347ec0f6f3f63aab58e63b6449583df5658a91972a20291c6311b5b3e5240aff8d7d00212278dfeae9949f887b70ae81e084f8897a5054627acef3efd01c8b29793d522ca2ced953b7fb95e3ba986333da9e69cd355223c929731094b6c2174c7638d2e60040850b766b126a2b4843fcdfdffa5d5cab3f53bc860a3bef68958b5f066177097b04c2aa045a0deffcaca41c5ac92e694466578f5909e72bb78d33310f705cc2dcaa338b312112db04b435a706d63244dd435238f0aa1e9e1598d354708102dcc4273c8a0ed2337ecf7879380a07e7d427c7f9d82e538002bd1442978402cdaf63debf5b40df902dae98dadc029f281474d190cddecef1b10653248a234151f91982912012669f74d0cfa1030ff37b152324e5b8346b3335a0aaeb63a0a2de2bca6a8d987d668defba89dc082196a922634ed88e065c669e526bb8815ee1be8ae2ad91d463bab75ee941d33cc5817b613c63cda943a4c07f600591b088a25d53fdee371cef596766823f4a518a583b1158243afe89700f0da76da46d0060f15d2444cefe7914c9a61e829c730eceb216288fee825f6b3b6298f6f6b6bd62e4c57a617a0aa10ea7a83aa6b6b0ed685b6a3d9e5b8fd14f56cdc18021b12253f3fd4915c19bd831a7920be55d969b2ac23359e2559da77de2373f06ca014ba2787d063cd07ee4944222b7762840eb94c688bec743fa8bdf7715c8fe29f104c2a01d5da2337fc1112bfa248db08ddea445c076abf3831c9dc3f0defa9ef1cd93a1e018e048fff5dc45cab533adc61fdafdc6f27c199b96f7fd08060997e583a5a639e03a080808008858180800880808080080000a95bd7f77cecf742e4485864c16f9a152a285f55312893ad55bafea1b57eb00f72e5a6e512dd41dba9da5eaa9d79de159751aa746639359a7fbc7b0f2cd636a0c40481b1e27f39c3e2aefe4ea0c8859565161e2bd6c916e4fab7dc252738e4ddf69c30e7f9ce5a773c8cbc9092e176c3e0e4e6d08e61b73d3bafeac2747bf4786add23c0be0439502618bb8cd0281bc5084b4ea2820d9406d6e47989475b7363bc57c8fef9e8c5f601a19d515a6ed205bad6b4f4c1fabf9430995c7d65015ca72b0b29598da1069139a8330a1c9ee273ae0b0bb1d3f2702b58806633b9bf84943d0cd34fcbbbe96bcfcbf988b394be31d394c866102d54a809460b9ef97bc6b19476ce1feea0e82a0206966fc33b51dde49c0b74ab7e797a1eba368e988c712f0125ff27ea6f5bb995e2678a06c0906d48f8462e322390ebb3fe99edb24f239eea33ed854ab4b19d83dc28268cb412f77bb365b0314ea98476ee8dd464f41aa29b54472bd50460505b16f4064af91516b7eed99cb9d2ea64a97f9dc708b4570fafcdd3ea19cbf0b331a0aabec88e3db98487d4ac2d087664f045832309e241a4dc719258a93d38ddc45533276f8aeb979e735adb7307c149ed5b7ff4a7b5f5a6221e0efdf0da3bc0a84cf85829ca89b6167998d214bdbdd2c1d011397ba37d4dd53804cce47f513259acc8edf83163072dbdadfc4cf36d950376e8e9791608b59ef25d755f72c6998badd443effa1bfede13b2ac79aa0b900d41faad4eb44cfa371f64119627b2c4f8777a7842c5c78d3f59d964305bd658bd72005988d7a15a92ff70f7221ee2e92aeb02eee7122699a887dac97e999b747a6e74b5bfa66b577d76dab76f970daca9ce0b939cd878e9aae517a7243c6375f4d98ec388055ead4a63ce20901650f2a2c5fe60d67a66044f2b2477e0780dc4767620a87de5f18298f1a7924669b58710e4a131c7674a8e7a8749d251e96bb1101a6d318dc3cecb0c826d050e60f38d8eb02d24a8217e7e82a3c89a7e1c9a01741ec00017ad609481cf9b99d2c22ac43a83e412802d60402fea34a6bb1e31432b4a2f7ce761da0968401e0190a93601dbce2550910a40000bd980fae617c9eb8c689a883bf0740f5cf87a4620b82ed6000001207a636173685f636c69656e745f6261636b656e643a6f75747075745f696e666f1202d4f10067c28046079b172dcbbf29e8c100011374ba65d7a0ddf1b381a2054328a0b20b64d345089cae591a6f9f1b4cbec90503904e0062577706204ff47400f1b1942b3970b364893c68b671a46aab8120352db0813400010800e7497597d4f9fcc89b6716d8a427b78d964335033674498dc982b4be1424".hexadecimal

//func hexEncodedString() -> String {
//    return map { String(format: "%02hhx", $0) }.joined()
//}
