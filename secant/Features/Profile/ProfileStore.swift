import ComposableArchitecture
import SwiftUI

typealias ProfileStore = Store<ProfileReducer.State, ProfileReducer.Action>
typealias ProfileViewStore = ViewStore<ProfileReducer.State, ProfileReducer.Action>

struct ProfileReducer: ReducerProtocol {
    struct State: Equatable {
        enum Destination {
            case addressDetails
            case settings
        }

        var address = ""
        var addressDetailsState: AddressDetailsReducer.State
        var appBuild = ""
        var appVersion = ""
        var destination: Destination?
        var sdkVersion = ""
        var settingsState: SettingsReducer.State
    }

    enum Action: Equatable {
        case addressDetails(AddressDetailsReducer.Action)
        case back
        case onAppear
        case onAppearFinished(String)
        case settings(SettingsReducer.Action)
        case updateDestination(ProfileReducer.State.Destination?)
    }
    
    @Dependency(\.appVersion) var appVersion
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.addressDetailsState, action: /Action.addressDetails) {
            AddressDetailsReducer()
        }

        Scope(state: \.settingsState, action: /Action.settings) {
            SettingsReducer()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                return Effect.task {
                    let saplingAddress = await self.sdkSynchronizer.getSaplingAddress()?.stringEncoded ?? ""
                    return .onAppearFinished(saplingAddress)
                }

            case let .onAppearFinished(saplingAddress):
                state.address = saplingAddress
                state.appBuild = appVersion.appBuild()
                state.appVersion = appVersion.appVersion()
                state.sdkVersion = zcashSDKEnvironment.sdkVersion
                return .none

            case .back:
                return .none
                
            case let .updateDestination(destination):
                state.destination = destination
                return .none
                
            case .addressDetails:
                return .none
                
            case .settings:
                return .none
            }
        }
    }
}

// MARK: - Store

extension ProfileStore {
    func settingsStore() -> SettingsStore {
        self.scope(
            state: \.settingsState,
            action: ProfileReducer.Action.settings
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

    var bindingForSettings: Binding<Bool> {
        self.destinationBinding.map(
            extract: { $0 == .settings },
            embed: { $0 ? .settings : nil }
        )
    }
}

// MARK: - Placeholders

extension ProfileReducer.State {
    static var placeholder: Self {
        .init(
            addressDetailsState: .placeholder,
            destination: nil,
            settingsState: .placeholder
        )
    }
}
