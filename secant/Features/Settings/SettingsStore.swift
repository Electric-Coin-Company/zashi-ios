import ComposableArchitecture
import SwiftUI

typealias SettingsReducer = Reducer<SettingsState, SettingsAction, SettingsEnvironment>
typealias AnySettingsReducer = AnyReducer<RecoveryPhraseDisplayReducer.State, RecoveryPhraseDisplayReducer.Action, SettingsEnvironment>
typealias SettingsStore = Store<SettingsState, SettingsAction>
typealias SettingsViewStore = ViewStore<SettingsState, SettingsAction>

// MARK: - State

struct SettingsState: Equatable {
    enum Route {
        case backupPhrase
    }

    var phraseDisplayState: RecoveryPhraseDisplayReducer.State
    var rescanDialog: ConfirmationDialogState<SettingsAction>?
    var route: Route?
}

// MARK: - Action

enum SettingsAction: Equatable {
    case backupWallet
    case backupWalletAccessRequest
    case cancelRescan
    case fullRescan
    case phraseDisplay(RecoveryPhraseDisplayReducer.Action)
    case quickRescan
    case rescanBlockchain
    case updateRoute(SettingsState.Route?)
}

// MARK: - Environment

struct SettingsEnvironment {
    let localAuthenticationHandler: LocalAuthenticationHandler
    let mnemonic: WrappedMnemonic
    let SDKSynchronizer: WrappedSDKSynchronizer
    let userPreferencesStorage: UserPreferencesStorage
    let walletStorage: WrappedWalletStorage
}

// MARK: - Reducer

extension SettingsReducer {
    static let `default` = SettingsReducer.combine(
        [
            settingsReducer,
            backupPhraseReducer
        ]
    )
    
    private static let settingsReducer = SettingsReducer { state, action, environment in
        switch action {
        case .backupWalletAccessRequest:
            return .run { send in
                if await environment.localAuthenticationHandler.authenticate() {
                    await send(.backupWallet)
                }
            }
            
        case .backupWallet:
            do {
                let storedWallet = try environment.walletStorage.exportWallet()
                let phraseWords = try environment.mnemonic.asWords(storedWallet.seedPhrase)
                let recoveryPhrase = RecoveryPhrase(words: phraseWords)
                state.phraseDisplayState.phrase = recoveryPhrase
                return Effect(value: .updateRoute(.backupPhrase))
            } catch {
                // TODO [#201]: - merge with issue 201 (https://github.com/zcash/secant-ios-wallet/issues/201) and its Error States
                return .none
            }
            
        case .cancelRescan, .quickRescan, .fullRescan:
            state.rescanDialog = nil
            return .none
            
        case .rescanBlockchain:
            state.rescanDialog = .init(
                title: TextState("Rescan"),
                message: TextState("Select the rescan you want"),
                buttons: [
                    .default(TextState("Quick rescan"), action: .send(.quickRescan)),
                    .default(TextState("Full rescan"), action: .send(.fullRescan)),
                    .cancel(TextState("Cancel"))
                ]
            )
            return .none
            
        case .phraseDisplay:
            state.route = nil
            return .none
            
        case .updateRoute(let route):
            state.route = route
            return .none
        }
    }
    
    private static let backupPhraseReducer: SettingsReducer = AnySettingsReducer { _ in
        RecoveryPhraseDisplayReducer()
    }
    .pullback(
        state: \SettingsState.phraseDisplayState,
        action: /SettingsAction.phraseDisplay,
        environment: { $0 }
    )
}

// MARK: - ViewStore

extension SettingsViewStore {
    var routeBinding: Binding<SettingsState.Route?> {
        self.binding(
            get: \.route,
            send: SettingsAction.updateRoute
        )
    }

    var bindingForBackupPhrase: Binding<Bool> {
        self.routeBinding.map(
            extract: { $0 == .backupPhrase },
            embed: { $0 ? .backupPhrase : nil }
        )
    }
}

// MARK: - Store

extension SettingsStore {
    func backupPhraseStore() -> RecoveryPhraseDisplayStore {
        self.scope(
            state: \.phraseDisplayState,
            action: SettingsAction.phraseDisplay
        )
    }
}

// MARK: Placeholders

extension SettingsState {
    static let placeholder = SettingsState(
        phraseDisplayState: RecoveryPhraseDisplayReducer.State(
            phrase: .placeholder
        )
    )
}

extension SettingsStore {
    static let placeholder = SettingsStore(
        initialState: .placeholder,
        reducer: .default,
        environment: SettingsEnvironment(
            localAuthenticationHandler: .live,
            mnemonic: .live,
            SDKSynchronizer: MockWrappedSDKSynchronizer(),
            userPreferencesStorage: .live,
            walletStorage: .live()
        )
    )
}
