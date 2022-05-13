import ComposableArchitecture
import SwiftUI

typealias ProfileReducer = Reducer<ProfileState, ProfileAction, ProfileEnvironment>
typealias ProfileStore = Store<ProfileState, ProfileAction>
typealias ProfileViewStore = ViewStore<ProfileState, ProfileAction>

// MARK: - State

struct ProfileState: Equatable {
    enum Route {
        case settings
        case walletInfo
    }

    var walletInfoState: WalletInfoState
    var settingsState: SettingsState
    var route: Route?
}

// MARK: - Action

enum ProfileAction: Equatable {
    case updateRoute(ProfileState.Route?)
}

// MARK: - Environment

struct ProfileEnvironment { }

// MARK: - Reducer

extension ProfileReducer {
    static let `default` = ProfileReducer { state, action, _ in
        switch action {
        case let .updateRoute(route):
            state.route = route
            return .none
        }
    }
}

// MARK: - ViewStore

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

// MARK: Placeholders

extension ProfileState {
    static var placeholder: Self {
        .init(
            walletInfoState: .init(),
            settingsState: .init(),
            route: nil
        )
    }
}
