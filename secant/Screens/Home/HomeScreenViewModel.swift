//
//  HomeScreenViewModel.swift
//  secant
//
//  Created by Francisco Gindre on 8/9/21.
//

import Combine
import Foundation

class HomeScreenViewModel: BaseViewModel<Services>, ObservableObject {
    enum Status {
        case syncing(progress: Float)
        case offline
        case error(error: Error)
    }

    @Published var balance: WalletBalance = Balance.nullBalance
    @Published var fiatConversion: Decimal = 0
    @Published var status = Status.offline
}

extension HomeScreenViewModel {
    static func mockWithValues(
        services: Services,
        status: Status,
        balance: WalletBalance,
        fiatConversion: Decimal
    ) -> HomeScreenViewModel {
        let viewModel = HomeScreenViewModel(services: services)
        viewModel.status = status
        viewModel.balance = balance
        viewModel.fiatConversion = fiatConversion

        return viewModel
    }
}
