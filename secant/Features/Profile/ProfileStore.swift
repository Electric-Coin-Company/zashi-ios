import ComposableArchitecture
import SwiftUI

typealias ProfileStore = Store<ProfileReducer.State, ProfileReducer.Action>
typealias ProfileViewStore = ViewStore<ProfileReducer.State, ProfileReducer.Action>

struct ProfileReducer: ReducerProtocol {
    struct State: Equatable {
        enum Route {
            case addressDetails
            case settings
        }

        var address = ""
        var addressDetailsState: AddressDetailsReducer.State
        var appBuild = ""
        var appVersion = ""
        var route: Route?
        var sdkVersion = ""
        var settingsState: SettingsReducer.State
    }

    enum Action: Equatable {
        case addressDetails(AddressDetailsReducer.Action)
        case back
        case onAppear
        case settings(SettingsReducer.Action)
        case updateRoute(ProfileReducer.State.Route?)
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
                state.address = sdkSynchronizer.getShieldedAddress() ?? ""
                state.appBuild = appVersion.appBuild()
                state.appVersion = appVersion.appVersion()
                state.sdkVersion = zcashSDKEnvironment.sdkVersion
                return .none
                
            case .back:
                return .none
                
            case let .updateRoute(route):
                state.route = route
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
    var routeBinding: Binding<ProfileReducer.State.Route?> {
        self.binding(
            get: \.route,
            send: ProfileReducer.Action.updateRoute
        )
    }

    var bindingForAddressDetails: Binding<Bool> {
        self.routeBinding.map(
            extract: { $0 == .addressDetails },
            embed: { $0 ? .addressDetails : nil }
        )
    }

    var bindingForSettings: Binding<Bool> {
        self.routeBinding.map(
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
            route: nil,
            settingsState: .placeholder
        )
    }
}
