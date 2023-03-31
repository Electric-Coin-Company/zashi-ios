//
//  AlertReducer.swift
//  secant
//
//  Created by Lukáš Korba on 28.03.2023.
//

import ComposableArchitecture

extension ReducerProtocol<RootReducer.State, RootReducer.Action> {
    func alerts() -> some ReducerProtocol<RootReducer.State, RootReducer.Action> {
        UniAlert(base: self)
    }
}

private struct UniAlert<Base: ReducerProtocol<RootReducer.State, RootReducer.Action>>: ReducerProtocol {
    let base: Base
    
    var body: some ReducerProtocol<RootReducer.State, RootReducer.Action> {
        base
        catchAlertRequests
        passAlertActions
    }
    
    // Catching the alert side effects
    @ReducerBuilder<State, Action>
    var catchAlertRequests: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .alert(let alert):
                state.uniAlert = alert.alertState()
                return .none

            case .exportLogs(.alert(let alert)):
                state.uniAlert = alert.alertState()
                return .none
            case .home(.settings(.exportLogs(.alert(let alert)))):
                state.uniAlert = alert.alertState()
                return .none

            case .home(.alert(let alert)):
                state.uniAlert = alert.alertState()
                return .none

            case .home(.balanceBreakdown(.alert(let alert))):
                state.uniAlert = alert.alertState()
                return .none

            case .home(.send(.scan(.alert(let alert)))):
                state.uniAlert = alert.alertState()
                return .none

            case .onboarding(.importWallet(.alert(let alert))):
                state.uniAlert = alert.alertState()
                return .none

            case .home(.settings(.alert(let alert))):
                state.uniAlert = alert.alertState()
                return .none

            case .home(.walletEvents(.alert(let alert))):
                state.uniAlert = alert.alertState()
                return .none

            default: return .none
            }
        }
    }
    
    // Passing alert actions back to the children
    @ReducerBuilder<State, Action>
    var passAlertActions: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .dismissAlert:
                state.uniAlert = nil
                return .none

            case .uniAlert(.balanceBreakdown(let action)):
                guard let action else { return .none }
                return EffectTask(value: .home(.balanceBreakdown(action)))

            case .uniAlert(.exportLogs(let action)):
                guard let action else { return .none }
                return .concatenate(
                    EffectTask(value: .exportLogs(action)),
                    EffectTask(value: .home(.settings(.exportLogs(action))))
                )

            case .uniAlert(.home(let action)):
                guard let action else { return .none }
                return EffectTask(value: .home(action))

            case .uniAlert(.importWallet(let action)):
                guard let action else { return .none }
                return EffectTask(value: .onboarding(.importWallet(action)))

            case .uniAlert(.root(let action)):
                guard let action else { return .none }
                return EffectTask(value: action)

            case .uniAlert(.scan(let action)):
                guard let action else { return .none }
                return EffectTask(value: .home(.send(.scan(action))))

            case .uniAlert(.settings(let action)):
                guard let action else { return .none }
                return EffectTask(value: .home(.settings(action)))

            case .uniAlert(.walletEvents(let action)):
                guard let action else { return .none }
                return EffectTask(value: .home(.walletEvents(action)))

            default: return .none
            }
        }
    }
}
