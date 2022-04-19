import ComposableArchitecture
import SwiftUI

struct HomeState: Equatable {
    var totalBalance: Double
    var verifiedBalance: Double
    var arePublishersPrepared = false
}

enum HomeAction: Equatable {
    case debugMenuStartup
    case preparePublishers
    case updateBalance(Balance)
}

struct HomeEnvironment {
    let combineSynchronizer: CombineSynchronizer
}

// MARK: - HomeReducer

typealias HomeReducer = Reducer<HomeState, HomeAction, HomeEnvironment>

extension HomeReducer {
    static let `default` = HomeReducer { state, action, environment in
        switch action {
        case .preparePublishers:
            if !state.arePublishersPrepared {
                state.arePublishersPrepared = true
                
                return environment.combineSynchronizer.shieldedBalance
                    .receive(on: DispatchQueue.main)
                    .map({ Balance(verified: $0.verified, total: $0.total) })
                    .map(HomeAction.updateBalance)
                    .eraseToEffect()
            }
            return .none
            
        case .updateBalance(let balance):
            state.totalBalance = balance.total.asHumanReadableZecBalance()
            state.verifiedBalance = balance.verified.asHumanReadableZecBalance()
            return .none
            
        case .debugMenuStartup:
            return .none
        }
    }
}

// MARK: - HomeStore

typealias HomeStore = Store<HomeState, HomeAction>

// MARK: PlaceHolders
extension HomeState {
    static var placeholder: Self {
        .init(
            totalBalance: 0.0,
            verifiedBalance: 0.0
        )
    }
}
