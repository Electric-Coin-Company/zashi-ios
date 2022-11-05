import ComposableArchitecture
import SwiftUI

typealias SettingsStore = Store<SettingsReducer.State, SettingsReducer.Action>
typealias SettingsViewStore = ViewStore<SettingsReducer.State, SettingsReducer.Action>

struct SettingsReducer: ReducerProtocol {
    struct State: Equatable {
        enum Route {
            case backupPhrase
        }

        var phraseDisplayState: RecoveryPhraseDisplayReducer.State
        var rescanDialog: ConfirmationDialogState<SettingsReducer.Action>?
        var route: Route?
    }

    enum Action: Equatable {
        case backupWallet
        case backupWalletAccessRequest
        case cancelRescan
        case fullRescan
        case phraseDisplay(RecoveryPhraseDisplayReducer.Action)
        case quickRescan
        case rescanBlockchain
        case updateRoute(SettingsReducer.State.Route?)
    }
    
    @Dependency(\.mnemonic) var mnemonic
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.walletStorage) var walletStorage
    @Dependency(\.localAuthenticationHandler) var localAuthenticationHandler

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .backupWalletAccessRequest:
                return .run { send in
                    if await localAuthenticationHandler.authenticate() {
                        await send(.backupWallet)
                    }
                }
                
            case .backupWallet:
                do {
                    let storedWallet = try walletStorage.exportWallet()
                    let phraseWords = try mnemonic.asWords(storedWallet.seedPhrase)
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

        Scope(state: \.phraseDisplayState, action: /Action.phraseDisplay) {
            RecoveryPhraseDisplayReducer()
        }
    }
}

// MARK: - ViewStore

extension SettingsViewStore {
    var routeBinding: Binding<SettingsReducer.State.Route?> {
        self.binding(
            get: \.route,
            send: SettingsReducer.Action.updateRoute
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
            action: SettingsReducer.Action.phraseDisplay
        )
    }
}

// MARK: Placeholders

extension SettingsReducer.State {
    static let placeholder = SettingsReducer.State(
        phraseDisplayState: RecoveryPhraseDisplayReducer.State(
            phrase: .placeholder
        )
    )
}

extension SettingsStore {
    static let placeholder = SettingsStore(
        initialState: .placeholder,
        reducer: SettingsReducer()
    )
}
