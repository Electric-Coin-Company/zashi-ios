import ComposableArchitecture
import SwiftUI

typealias ProfileReducer = Reducer<ProfileState, ProfileAction, ProfileEnvironment>
typealias ProfileStore = Store<ProfileState, ProfileAction>
typealias ProfileViewStore = ViewStore<ProfileState, ProfileAction>

// MARK: - State

struct ProfileState: Equatable {
    enum Route {
        case phraseDisplay
        case settings
        case walletInfo
    }

    var phraseDisplayState: RecoveryPhraseDisplayState
    var route: Route?
    var settingsState: SettingsState
    var walletInfoState: WalletInfoState
}

// MARK: - Action

enum ProfileAction: Equatable {
    case phraseDisplay(RecoveryPhraseDisplayAction)
    case updateRoute(ProfileState.Route?)
}

// MARK: - Environment

struct ProfileEnvironment {
    let mnemonic: WrappedMnemonic
    let walletStorage: WrappedWalletStorage
}

extension ProfileEnvironment {
    static let live = ProfileEnvironment(
        mnemonic: .live,
        walletStorage: .live()
    )

    static let mock = ProfileEnvironment(
        mnemonic: .mock,
        walletStorage: .live()
    )
}

// MARK: - Reducer

extension ProfileReducer {
    static let `default` = ProfileReducer { state, action, environment in
        switch action {
        case .updateRoute(.phraseDisplay):
            do {
                let storedWallet = try environment.walletStorage.exportWallet()
                let phraseWords = try environment.mnemonic.asWords(storedWallet.seedPhrase)
                
                let recoveryPhrase = RecoveryPhrase(words: phraseWords)
                state.phraseDisplayState.phrase = recoveryPhrase
                state.route = .phraseDisplay
            } catch {
                // TODO: - merge with issue 201 (https://github.com/zcash/secant-ios-wallet/issues/201) and its Error States
                return .none
            }
            return .none

        case let .updateRoute(route):
            state.route = route
            return .none
        
        case .phraseDisplay(.finishedPressed):
            state.route = nil
            return .none
            
        case .phraseDisplay:
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

    var bindingForPhraseDisplay: Binding<Bool> {
        self.routeBinding.map(
            extract: { $0 == .phraseDisplay },
            embed: { $0 ? .phraseDisplay : nil }
        )
    }
}

// MARK: Placeholders

extension ProfileState {
    static var placeholder: Self {
        .init(
            phraseDisplayState: .init(),
            route: nil,
            settingsState: .init(),
            walletInfoState: .init()
        )
    }
}
