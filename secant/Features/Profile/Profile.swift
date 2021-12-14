import ComposableArchitecture
import SwiftUI

struct ProfileState: Equatable {
    enum Route {
        case settings
        case walletInfo
    }

    var walletInfoState: WalletInfoState
    var settingsState: SettingsState
    var route: Route?
}

enum ProfileAction: Equatable {
    case updateRoute(ProfileState.Route?)
}

struct ProfileEnvironment {
}

// MARK: - ProfileReducer

typealias ProfileReducer = Reducer<ProfileState, ProfileAction, ProfileEnvironment>

extension ProfileReducer {
    static let `default` = ProfileReducer { state, action, environment in
        switch action {
        case let .updateRoute(route):
            state.route = route
            return .none
        }
    }
}

// MARK: - ProfileStore

typealias ProfileStore = Store<ProfileState, ProfileAction>

extension ProfileStore {
}

// MARK: - ProfileViewStore

typealias ProfileViewStore = ViewStore<ProfileState, ProfileAction>

extension ProfileViewStore {
    var routeBinding: Binding<ProfileState.Route?> {
        self.binding(
            get: \.route,
            send: ProfileAction.updateRoute
        )
    }

    var bindingForWalletInfo: Binding<Bool> {
        self.routeBinding.map(
            extract: { $0 == .walletInfo },
            embed: { $0 ? .walletInfo : nil }
        )
    }

    var bindingForSettings: Binding<Bool> {
        self.routeBinding.map(
            extract: { $0 == .settings },
            embed: { $0 ? .settings : nil }
        )
    }
}

// MARK: PlaceHolders

extension ProfileState {
    static var placeholder: Self {
        .init(
            walletInfoState: .init(),
            settingsState: .init(),
            route: nil
        )
    }
}

