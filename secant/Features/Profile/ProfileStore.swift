import ComposableArchitecture
import SwiftUI
import ZcashLightClientKit
import AppVersion
import Generated

typealias ProfileStore = Store<ProfileReducer.State, ProfileReducer.Action>
typealias ProfileViewStore = ViewStore<ProfileReducer.State, ProfileReducer.Action>

struct ProfileReducer: ReducerProtocol {
    struct State: Equatable {
        enum Destination {
            case addressDetails
        }

        var addressDetailsState: AddressDetailsReducer.State
        var appBuild = ""
        var appVersion = ""
        var destination: Destination?
        var sdkVersion = ""
        
        var unifiedAddress: String {
            addressDetailsState.uAddress?.stringEncoded ?? L10n.ReceiveZec.Error.cantExtractUnifiedAddress
        }
    }

    enum Action: Equatable {
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

    var body: some ReducerProtocol<State, Action> {
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
    func addressStore() -> AddressDetailsStore {
        self.scope(
            state: \.addressDetailsState,
            action: ProfileReducer.Action.addressDetails
        )
    }
}

// MARK: - ViewStore

extension ProfileViewStore {
    var destinationBinding: Binding<ProfileReducer.State.Destination?> {
        self.binding(
            get: \.destination,
            send: ProfileReducer.Action.updateDestination
        )
    }

    var bindingForAddressDetails: Binding<Bool> {
        self.destinationBinding.map(
            extract: { $0 == .addressDetails },
            embed: { $0 ? .addressDetails : nil }
        )
    }
}

// MARK: - Placeholders

extension ProfileReducer.State {
    static var placeholder: Self {
        .init(
            addressDetailsState: .placeholder,
            destination: nil
        )
    }
}
