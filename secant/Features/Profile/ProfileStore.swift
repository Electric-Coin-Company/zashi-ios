import ComposableArchitecture
import SwiftUI

typealias ProfileReducer = Reducer<ProfileState, ProfileAction, ProfileEnvironment>
typealias ProfileStore = Store<ProfileState, ProfileAction>
typealias ProfileViewStore = ViewStore<ProfileState, ProfileAction>

typealias AnySettingsReducer = AnyReducer<SettingsReducer.State, SettingsReducer.Action, ProfileEnvironment>
typealias AnyAddressDetailsReducer = AnyReducer<AddressDetailsReducer.State, AddressDetailsReducer.Action, ProfileEnvironment>

// MARK: - State

struct ProfileState: Equatable {
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

// MARK: - Action

enum ProfileAction: Equatable {
    case addressDetails(AddressDetailsReducer.Action)
    case back
    case onAppear
    case settings(SettingsReducer.Action)
    case updateRoute(ProfileState.Route?)
}

// MARK: - Environment

struct ProfileEnvironment {
    let appVersionHandler: AppVersionHandler
    let mnemonic: WrappedMnemonic
    let SDKSynchronizer: WrappedSDKSynchronizer
    let walletStorage: WrappedWalletStorage
    let zcashSDKEnvironment: ZCashSDKEnvironment
}

extension ProfileEnvironment {
    static let live = ProfileEnvironment(
        appVersionHandler: .live,
        mnemonic: .live,
        SDKSynchronizer: LiveWrappedSDKSynchronizer(),
        walletStorage: .live(),
        zcashSDKEnvironment: .mainnet
    )

    static let mock = ProfileEnvironment(
        appVersionHandler: .test,
        mnemonic: .mock,
        SDKSynchronizer: MockWrappedSDKSynchronizer(),
        walletStorage: .live(),
        zcashSDKEnvironment: .testnet
    )
}

// MARK: - Reducer

extension ProfileReducer {
    static let `default` = ProfileReducer.combine(
        [
            profileReducer,
            addressDetailsReducer,
            settingsReducer
        ]
    )

    private static let profileReducer = ProfileReducer { state, action, environment in
        switch action {
        case .onAppear:
            state.address = environment.SDKSynchronizer.getShieldedAddress() ?? ""
            state.appBuild = environment.appVersionHandler.appBuild()
            state.appVersion = environment.appVersionHandler.appVersion()
            state.sdkVersion = environment.zcashSDKEnvironment.sdkVersion
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
    
    private static let addressDetailsReducer: ProfileReducer = AnyAddressDetailsReducer { _ in
        AddressDetailsReducer()
    }
    .pullback(
        state: \ProfileState.addressDetailsState,
        action: /ProfileAction.addressDetails,
        environment: { $0 }
    )

    private static let settingsReducer: ProfileReducer = AnySettingsReducer { _ in
        SettingsReducer()
    }
    .pullback(
        state: \ProfileState.settingsState,
        action: /ProfileAction.settings,
        environment: { $0 }
    )
}

// MARK: - Store

extension ProfileStore {
    func settingsStore() -> SettingsStore {
        self.scope(
            state: \.settingsState,
            action: ProfileAction.settings
        )
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

// MARK: Placeholders

extension ProfileState {
    static var placeholder: Self {
        .init(
            addressDetailsState: .placeholder,
            route: nil,
            settingsState: .placeholder
        )
    }
}
