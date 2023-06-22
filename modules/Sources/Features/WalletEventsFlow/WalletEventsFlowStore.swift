import ComposableArchitecture
import SwiftUI
import ZcashLightClientKit
import Utils
import Models
import Generated
import Pasteboard
import SDKSynchronizer
import ZcashSDKEnvironment

public typealias WalletEventsFlowStore = Store<WalletEventsFlowReducer.State, WalletEventsFlowReducer.Action>
public typealias WalletEventsFlowViewStore = ViewStore<WalletEventsFlowReducer.State, WalletEventsFlowReducer.Action>

public struct WalletEventsFlowReducer: ReducerProtocol {
    private enum CancelId { case timer }

    public struct State: Equatable {
        public enum Destination: Equatable {
            case latest
            case all
            case showWalletEvent(WalletEvent)
        }

        @PresentationState public var alert: AlertState<Action>?
        public var destination: Destination?
        public var latestMinedHeight: BlockHeight?
        public var isScrollable = true
        public var requiredTransactionConfirmations = 0
        public var walletEvents = IdentifiedArrayOf<WalletEvent>.placeholder
        public var selectedWalletEvent: WalletEvent?
        
        public init(
            destination: Destination? = nil,
            latestMinedHeight: BlockHeight? = nil,
            isScrollable: Bool = true,
            requiredTransactionConfirmations: Int = 0,
            walletEvents: IdentifiedArrayOf<WalletEvent> = .placeholder,
            selectedWalletEvent: WalletEvent? = nil
        ) {
            self.destination = destination
            self.latestMinedHeight = latestMinedHeight
            self.isScrollable = isScrollable
            self.requiredTransactionConfirmations = requiredTransactionConfirmations
            self.walletEvents = walletEvents
            self.selectedWalletEvent = selectedWalletEvent
        }
    }

    public enum Action: Equatable {
        case alert(PresentationAction<Action>)
        case copyToPastboard(RedactableString)
        case onAppear
        case onDisappear
        case openBlockExplorer(URL?)
        case updateDestination(WalletEventsFlowReducer.State.Destination?)
        case replyTo(RedactableString)
        case synchronizerStateChanged(SyncStatus)
        case updateWalletEvents([WalletEvent])
        case warnBeforeLeavingApp(URL?)
    }
    
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.pasteboard) var pasteboard
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    public init() {}
    
    // swiftlint:disable:next cyclomatic_complexity
    public func reduce(into state: inout State, action: Action) -> ComposableArchitecture.EffectTask<Action> {
        switch action {
        case .onAppear:
            state.requiredTransactionConfirmations = zcashSDKEnvironment.requiredTransactionConfirmations
            return sdkSynchronizer.stateStream()
                .throttle(for: .seconds(0.2), scheduler: mainQueue, latest: true)
                .map { WalletEventsFlowReducer.Action.synchronizerStateChanged($0.syncStatus) }
                .eraseToEffect()
                .cancellable(id: CancelId.timer, cancelInFlight: true)

        case .onDisappear:
            return .cancel(id: CancelId.timer)

        case .synchronizerStateChanged(.upToDate):
            state.latestMinedHeight = sdkSynchronizer.latestScannedHeight()
            return .task {
                return .updateWalletEvents(try await sdkSynchronizer.getAllTransactions())
            }
            
        case .synchronizerStateChanged:
            return .none
            
        case .updateWalletEvents(let walletEvents):
            let sortedWalletEvents = walletEvents
                .sorted(by: { lhs, rhs in
                    guard let lhsTimestamp = lhs.timestamp, let rhsTimestamp = rhs.timestamp else {
                        return false
                    }
                    return lhsTimestamp > rhsTimestamp
                })
            state.walletEvents = IdentifiedArrayOf(uniqueElements: sortedWalletEvents)
            return .none

        case .updateDestination(.showWalletEvent(let walletEvent)):
            state.selectedWalletEvent = walletEvent
            state.destination = .showWalletEvent(walletEvent)
            return .none

        case .updateDestination(let destination):
            state.destination = destination
            if destination == nil {
                state.selectedWalletEvent = nil
            }
            return .none
            
        case .copyToPastboard(let value):
            pasteboard.setString(value)
            return .none
            
        case .replyTo:
            return .none

        case .alert(.presented(let action)):
            return EffectTask(value: action)

        case .alert(.dismiss):
            state.alert = nil
            return .none

        case .alert:
            return .none
            
        case .warnBeforeLeavingApp(let blockExplorerURL):
            state.alert = AlertState.warnBeforeLeavingApp(blockExplorerURL)
            return .none

        case .openBlockExplorer(let blockExplorerURL):
            if let url = blockExplorerURL {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            return .none
        }
    }
}

// MARK: - ViewStore

extension WalletEventsFlowViewStore {
    private typealias Destination = WalletEventsFlowReducer.State.Destination

    func bindingForSelectedWalletEvent(_ walletEvent: WalletEvent?) -> Binding<Bool> {
        self.binding(
            get: {
                guard let walletEvent else {
                    return false
                }
                
                return $0.destination.map(/WalletEventsFlowReducer.State.Destination.showWalletEvent) == walletEvent
            },
            send: { isActive in
                guard let walletEvent else {
                    return WalletEventsFlowReducer.Action.updateDestination(nil)
                }
                
                return WalletEventsFlowReducer.Action.updateDestination(
                    isActive ? WalletEventsFlowReducer.State.Destination.showWalletEvent(walletEvent) : nil
                )
            }
        )
    }
}

// MARK: Alerts

extension AlertState where Action == WalletEventsFlowReducer.Action {
    public static func warnBeforeLeavingApp(_ blockExplorerURL: URL?) -> AlertState {
        AlertState {
            TextState(L10n.WalletEvent.Alert.LeavingApp.title)
        } actions: {
            ButtonState(action: .openBlockExplorer(blockExplorerURL)) {
                TextState(L10n.WalletEvent.Alert.LeavingApp.Button.seeOnline)
            }
            ButtonState(role: .cancel, action: .alert(.dismiss)) {
                TextState(L10n.WalletEvent.Alert.LeavingApp.Button.nevermind)
            }
        } message: {
            TextState(L10n.WalletEvent.Alert.LeavingApp.message)
        }
    }
}

// MARK: Placeholders

extension TransactionState {
    public static var placeholder: Self {
        .init(
            zAddress: "t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po",
            fee: Zatoshi(10),
            id: "2",
            status: .paid(success: true),
            timestamp: 1234567,
            zecAmount: Zatoshi(123_000_000)
        )
    }
    
    public static func statePlaceholder(_ status: Status) -> Self {
        .init(
            zAddress: "t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po",
            fee: Zatoshi(10),
            id: "2",
            status: status,
            timestamp: 1234567,
            zecAmount: Zatoshi(123_000_000)
        )
    }
}

extension WalletEventsFlowReducer.State {
    public static var placeHolder: Self {
        .init(walletEvents: .placeholder)
    }

    public static var emptyPlaceHolder: Self {
        .init(walletEvents: [])
    }
}

extension WalletEventsFlowStore {
    public static var placeholder: Store<WalletEventsFlowReducer.State, WalletEventsFlowReducer.Action> {
        return Store(
            initialState: .placeHolder,
            reducer: WalletEventsFlowReducer()
                .dependency(\.zcashSDKEnvironment, .testnet)
        )
    }
}

extension IdentifiedArrayOf where Element == TransactionState {
    public static var placeholder: IdentifiedArrayOf<TransactionState> {
        return .init(
            uniqueElements: (0..<30).map {
                TransactionState(
                    fee: Zatoshi(10),
                    id: String($0),
                    status: .paid(success: true),
                    timestamp: 1234567,
                    zecAmount: Zatoshi(25)
                )
            }
        )
    }
}
