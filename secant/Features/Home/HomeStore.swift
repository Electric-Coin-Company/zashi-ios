import ComposableArchitecture
import SwiftUI

struct HomeState: Equatable {
    var balance: Double
}

enum HomeAction: Equatable {
}

// MARK: - HomeReducer

typealias HomeReducer = Reducer<HomeState, HomeAction, Void>

extension HomeReducer {
    static let `default` = HomeReducer { _, _, _ in
        return .none
    }
}

// MARK: - HomeStore

typealias HomeStore = Store<HomeState, HomeAction>

// MARK: PlaceHolders
extension HomeState {
    static var placeholder: Self {
        .init(
            balance: 1.2
        )
    }
}
