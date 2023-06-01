import ComposableArchitecture
import SwiftUI
import ZcashLightClientKit
import AppVersion
import Generated
import AddressDetails
import SDKSynchronizer
import ZcashSDKEnvironment

public typealias ProfileStore = Store<ProfileReducer.State, ProfileReducer.Action>
public typealias ProfileViewStore = ViewStore<ProfileReducer.State, ProfileReducer.Action>

public struct ProfileReducer: ReducerProtocol {
    public struct State: Equatable {
        public enum Destination {
            case addressDetails
        }

        public var addressDetailsState: AddressDetailsReducer.State
        public var appBuild = ""
        public var appVersion = ""
        public var destination: Destination?
        public var sdkVersion = ""
        
        public var unifiedAddress: String {
            addressDetailsState.uAddress?.stringEncoded ?? L10n.ReceiveZec.Error.cantExtractUnifiedAddress
        }
        
        public init(
            addressDetailsState: AddressDetailsReducer.State,
            appBuild: String = "",
            appVersion: String = "",
            destination: Destination? = nil,
            sdkVersion: String = ""
        ) {
            self.addressDetailsState = addressDetailsState
            self.appBuild = appBuild
            self.appVersion = appVersion
            self.destination = destination
            self.sdkVersion = sdkVersion
        }
    }

    public enum Action: Equatable {
        case addressDetails(AddressDetailsReducer.Action)
        case back
        case copyUnifiedAddressToPastboard
        case onAppear
        case uAddressChanged(UnifiedAddress?)
        case updateDestination(ProfileReducer.State.Destination?)
    }
    
    @Dependency(\.appVersion) var appVersion
    @Dependency(\.pasteboard) var pasteboard
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    public init() {}
    
    public var body: some ReducerProtocol<State, Action> {
        Scope(state: \.addressDetailsState, action: /Action.addressDetails) {
            AddressDetailsReducer()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                state.appBuild = appVersion.appBuild()
                state.appVersion = appVersion.appVersion()
                state.sdkVersion = zcashSDKEnvironment.sdkVersion
                return .task {
                    return .uAddressChanged(try? await sdkSynchronizer.getUnifiedAddress(0))
                }

            case .uAddressChanged(let uAddress):
                state.addressDetailsState.uAddress = uAddress
                return .none
                
            case .back:
                return .none
            
            case .copyUnifiedAddressToPastboard:
                pasteboard.setString(state.unifiedAddress.redacted)
                return .none
                
            case let .updateDestination(destination):
                state.destination = destination
                return .none
                
            case .addressDetails:
                return .none
            }
        }
    }
}

// MARK: - Store

extension ProfileStore {
    public func addressStore() -> AddressDetailsStore {
        self.scope(
            state: \.addressDetailsState,
            action: ProfileReducer.Action.addressDetails
        )
    }
}

// MARK: - ViewStore

extension ProfileViewStore {
    public var destinationBinding: Binding<ProfileReducer.State.Destination?> {
        self.binding(
            get: \.destination,
            send: ProfileReducer.Action.updateDestination
        )
    }

    public var bindingForAddressDetails: Binding<Bool> {
        self.destinationBinding.map(
            extract: { $0 == .addressDetails },
            embed: { $0 ? .addressDetails : nil }
        )
    }
}

// MARK: - Placeholders

extension ProfileReducer.State {
    public static var placeholder: Self {
        .init(
            addressDetailsState: .placeholder,
            destination: nil
        )
    }
}
